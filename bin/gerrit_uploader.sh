#!/bin/ksh -
set -Cefuo pipefail

usage() {
	printf "usage:\n\tgerrit_uploader.sh [target_branch]\n\n"
}

# TODO: add support for git-worktree(1)
if [[ ! -x "$(git rev-parse --absolute-git-dir)/hooks/commit-msg" ]] || ! grep -i gerrit "$(git rev-parse --absolute-git-dir)/hooks/commit-msg" >/dev/null 2>&1; then
	# IF commit-msg is not executable (or does not exist) OR commit-msg exists but is unrelated to gerrit, THEN
	printf "This script can only be used to upload changes to Gerrit Code Review.\n"
	printf "No commit-msg hook found.\n"
	exit 1
fi

# TODO: warn if the worktree contains unstaged commits, and offer to amend them into the current commit if the current author matches the author of the previous commit

if [[ "${#}" == '0' ]]; then
	UPSTREAM_BRANCH="$(git rev-parse --symbolic-full-name @\{u\} 2>/dev/null | awk -F'/' '{print $NF}')"
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
	printf "No upstream branch found. Please configure an upstream branch,\n"
	printf "using, e.g., 'git branch -u origin/main'\n\n"
	exit 1
elif ! git rev-parse --remotes "${UPSTREAM_BRANCH}" >/dev/null 2>&1; then
	printf "ERROR: cannot find remote tracking branch '%s', cancelling upload.\n" "${UPSTREAM_BRANCH}"
	exit 1
fi

if [[ "${UPSTREAM_BRANCH}" != 'main' ]] && [[ "${UPSTREAM_BRANCH}" != 'master' ]]; then
	printf "Non-standard upstream branch '%s' found. Proceed? (y/N) " "${UPSTREAM_BRANCH}"
	read -r yesno
	if [[ "${yesno}" != 'y' ]] && [[ "${yesno}" != 'yes' ]]; then
		printf "cancelling upload..\n"
		exit 0
	fi
fi

if git remote get-url --all gerrit >/dev/null 2>&1; then
	REMOTE='gerrit'; readonly REMOTE
elif git remote get-url --all origin >/dev/null 2>&1; then
	REMOTE='origin'; readonly REMOTE
else
	printf "please configure a remote url\n"
	exit 1
fi

# verify that pre-commit, if configured, is enabled
if [[ -r "$(git rev-parse --show-toplevel)/.pre-commit-config.yaml" ]] && [[ ! -x "$(git rev-parse --absolute-git-dir)/hooks/pre-commit" ]]; then
	printf "pre-commit not configured. Fixing and running linters.\n"
	printf "This may take a few minutes...\n"
	cd "$(git rev-parse --show-toplevel)"
	pre-commit install
	cd -
	pre-commit run --from-ref "$(git merge-base "@{u}" HEAD)" --to-ref HEAD
fi
# TODO: support uploading a rev other than HEAD; conditional on rewrite in a non-bourne language
exec git push "${REMOTE}" "HEAD:refs/for/${UPSTREAM_BRANCH}"
