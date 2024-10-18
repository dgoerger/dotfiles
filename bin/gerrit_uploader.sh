#!/bin/ksh -
set -Cefuo pipefail

usage() {
	printf "usage:\n\tgerrit_uploader.sh [target_branch]\n\n"
}

if git remote get-url --all gerrit >/dev/null 2>&1; then
	REMOTE='gerrit'; readonly REMOTE
elif git remote get-url --all origin >/dev/null 2>&1; then
	REMOTE='origin'; readonly REMOTE
else
	printf 'The current directory either is not a git repo, or has no remote url configured.\n'
	exit 1
fi

if [[ "${#}" == '0' ]]; then
	UPSTREAM_BRANCH="$(git rev-parse --symbolic-full-name "@{u}" 2>/dev/null | awk -F'/' '{print $NF}')"
	readonly UPSTREAM_BRANCH
elif [[ "${#}" == '1' ]]; then
	case "${1}" in
		-h|--help)
			usage
			exit 0
			;;
		*[!a-z0-9.-]*)
			printf "ERROR: invalid branch name '%s'\n" "${1}"
			usage
			exit 1
			;;
		*)
			UPSTREAM_BRANCH="${1}"
			readonly UPSTREAM_BRANCH
			;;
	esac
else
	usage
	exit 1
fi

if [[ -z "${UPSTREAM_BRANCH}" ]]; then
	printf "No upstream branch found. Please configure an upstream branch\n"
	printf "using, e.g., 'git branch -u origin/main'\n\n"
	exit 1
elif ! git fetch "${REMOTE}" "${UPSTREAM_BRANCH}" || ! git rev-parse --remotes "${UPSTREAM_BRANCH}" >/dev/null 2>&1; then
	printf "ERROR: cannot find remote tracking branch '%s', cancelling upload.\n" "${UPSTREAM_BRANCH}"
	exit 1
fi

# query git author information so we can compare with the author of the previous commit
if [[ -n "${GIT_AUTHOR_EMAIL}" ]]; then
	author_email="${GIT_AUTHOR_EMAIL}"
elif git config get user.email >/dev/null 2>&1; then
	author_email="$(git config get user.email 2>/dev/null)"
else
	printf "ERROR: please configure 'git config set user.email user@example.com'\n"
	exit 1
fi

does_previous_commit_have_same_author() {
	# warn if we're amending or uploading someone else's commit
	if [[ "${author_email}" != "$(git show -s --pretty=%ae 2>/dev/null)" ]]; then
		return 1
	else
		return 0
	fi
}

if ! git diff --quiet >/dev/null 2>&1; then
	printf "WARNING: the current worktree is dirty. Would you like to\n"
	printf "- (c)reate a new commit\n"
	printf "- (a)mend the previous commit\n"
	printf "- (p)rint the diff and exit\n\n"
	printf "Selection: "
	read -r createOrAmend
	case "${createOrAmend}" in
		c|create)
			git commit -a
			;;
		a|amend)
			if ! does_previous_commit_have_same_author; then
				printf "ERROR: The previous commit has a different author.\n"
				printf "       Please create a new commit.\n\n"
				printf "prev commit: %s\n" "$(git show -s --pretty=%ae 2>/dev/null)"
				printf "your email: %s\n" "${author_email}"
				exit 1
			fi

			if [[ "$(git log --oneline "$(git merge-base "@{u}" HEAD)" ^HEAD | wc -l)" == '0' ]]; then
				printf "ERROR: The previous commit is already merged upstream.\n"
				printf "       Please create a new commit.\n\n"
				exit 1
			fi
			git commit -a --amend
			;;
		p|print)
			git diff
			exit 1
			;;
		*)
			exit 1
			;;
	esac
elif ! does_previous_commit_have_same_author; then
	printf "WARNING: You're about to upload a change written by '%s'.\n" "$(git show -s --pretty=%ae 2>/dev/null)"
	printf "Would you like to\n"
	printf "- (c)ontinue anyway\n"
	printf "- (r)eset the author (claim authorship)\n"
	printf "- (p)rint the diff and exit\n\n"
	printf "Selection: "
	read -r continueResetAbort
	case "${continueResetAbort}" in
		c|continue)
			;;
		r|reset)
			printf "really claim authorship? (y/N) "
			read -r yesno
			case "${yesno}" in
				y|yes|Y|YES)
					git commit --amend --reset-author --no-edit
					;;
				*)
					printf "cancelling upload..\n\n"
					exit 1
					;;
			esac
			;;
		p|print)
			git show --pretty=medium
			exit 1
			;;
		*)
			exit 1
			;;
	esac
fi

# TODO: add support for git-worktree(1)
if [[ ! -x "$(git rev-parse --absolute-git-dir)/hooks/commit-msg" ]] || ! grep -i gerrit "$(git rev-parse --absolute-git-dir)/hooks/commit-msg" >/dev/null 2>&1; then
	# IF commit-msg is not executable (or does not exist) OR commit-msg exists but is unrelated to gerrit, THEN
	printf "This script can only be used to upload changes to Gerrit Code Review.\n"
	printf "No commit-msg hook found.\n\n"
	remote_clone_url="$(git remote get-url "${REMOTE}" 2>/dev/null)"; readonly remote_clone_url
	case "${remote_clone_url}" in
		ssh*)
			commit_msg_url="$(printf 'https://%s/tools/hooks/commit-msg' "$(echo "${remote_clone_url}" | awk -F':' '{print $2}' | sed 's/.*\@//' | sed 's/\/\///')")"
			;;
		https*)
			commit_msg_url="$(printf 'https://%s/tools/hooks/commit-msg' "$(echo "${remote_clone_url}" | awk -F'/' '{print $3}' | sed 's/.*\@//' | sed 's/\/\///')")"
			;;
		*)
			exit 1
			;;
	esac
	readonly commit_msg_url
	printf "Install the hook and amend the most recent commit to add a Gerrit Change-Id? (y/N)\n"
	read -r yesno
	case "${yesno}" in
		y*|Y*)
			mkdir -p "$(git rev-parse --git-dir)/hooks"
			if [[ -f "$(git rev-parse --git-dir)/hooks/commit-msg" ]]; then
				timestamp="$(date +%Y%m%d%H%M%S)"; readonly timestamp
				mv "$(git rev-parse --git-dir)/hooks/commit-msg" "$(git rev-parse --git-dir)/hooks/commit-msg.${timestamp}"
			fi
			curl -Lo "$(git rev-parse --git-dir)/hooks/commit-msg" "${commit_msg_url}"
			chmod +x "$(git rev-parse --git-dir)/hooks/commit-msg"
			if does_previous_commit_have_same_author; then
				git commit --amend --no-edit
			else
				printf "ERROR: The previous commit has a different author! Refusing to amend.\n"
				exit 1
			fi
			;;
		*)
			exit 1
			;;
	esac
fi

if [[ "${UPSTREAM_BRANCH}" != 'main' ]] && [[ "${UPSTREAM_BRANCH}" != 'master' ]]; then
	printf "Non-standard upstream branch '%s' found. Proceed? (y/N) " "${UPSTREAM_BRANCH}"
	read -r yesno
	if [[ "${yesno}" != 'y' ]] && [[ "${yesno}" != 'yes' ]]; then
		printf "cancelling upload..\n"
		exit 0
	fi
fi

# warn if we're uploading more than one change at a time
number_of_commits_since_merge_base="$(git log --oneline "$(git merge-base "@{u}" HEAD)" ^HEAD | wc -l)"
readonly number_of_commits_since_merge_base
if [[ "${number_of_commits_since_merge_base}" -gt 1 ]]; then
	printf "WARNING: You're about to upload %s changes. Proceed? (y/N) " "${number_of_commits_since_merge_base}"
	read -r yesno
	case "${yesno}" in
		y|yes|Y|YES)
			;;
		*)
			printf "Cancelling upload. Your merge base is\n"
			git show -s --pretty=medium "$(git merge-base "@{u}" HEAD)"
			exit 1
			;;
	esac
fi

# run pre-commit as a pre-upload step
if [[ -r "$(git rev-parse --show-toplevel)/.pre-commit-config.yaml" ]]; then
	pre-commit run --from-ref "$(git merge-base "@{u}" HEAD)" --to-ref HEAD
fi

# TODO: support uploading a rev other than HEAD
exec git push "${REMOTE}" "HEAD:refs/for/${UPSTREAM_BRANCH}"
