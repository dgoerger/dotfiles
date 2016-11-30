I thought this was a dotfiles repo?
-----------------------------------

It was. Originally. But over time, it grew in scope, eventually managing system-level configs in order to assist with freqent system reinstalls. To help automate package installation and config placement, I wrote the first draft of `postinstall.sh`.

After months of this arrangement, I realized I had half a dozen systems all at different epochs of this dotfiles config, each essentially frozen at whatever commit had been current at the time of the system's installation. While this works fine for some configs, it's kind of annoying for others, especially if I've fixed a bug one place and the fix doesn't automatically propagate to the other machines...

Enter chef configuration management. I write chef code for work; it was an easy port from bash to chef/ruby. Ansible would've been easier---eh, maybe I'll port it some day.


This config is very.. opinionated
---------------------------------

Yes, yes it is. Feel free to fork. ;)

If you have something you think should be merged into this repo, please file a bug or pull request. Thanks!


Usage
-----

**FORK THIS REPO IF YOU INTEND TO MAKE CHANGES. CHAKE SETS UP A CRON GIT-PULL---DON'T LOCK YOURSELF TO MY REPO UNLESS YOU INTEND TO ACCEPT MY OPINIONATED CODE. YOU HAVE BEEN WARNED.**

On a freshly-installed Fedora system (I follow upstream pretty closely), run:

```
$ curl -L https://github.com/dgoerger/dotfiles/raw/master/postinstall.sh -o /tmp/postinstall.sh
$ chmod +x /tmp/postinstall.sh
$ # READ THE CODE BEFORE EXECUTING IT !!
$ vi /tmp/postinstall.sh
$ # if you're ready, go for it
$ sh /tmp/postinstall.sh
```

After the script finishes, you'll want to

  1. if you didn't already fork, edit the attributes file(s) in `/var/chake/cookbooks/workstation/attributes/`
  2. seriously though fork this repo and commit your deltas
  3. as root, `cd /var/chake && rake converge`
  4. copy in secrets, and declare them in `~/.bashrc`


Secrets
-------

`$MUTTRC` is called by `/etc/Muttrc.local`, and should point to a password-protected gpg file containing something along the lines of:

```
# whoami
set from = 'your email address'
set realname = 'your name'
# server connection
set folder = 'imaps://fqdn:port/'
set imap_user = 'username'
set smtp_url = 'smtps://username@fqdn:port/'
# folders to list in the sidebar
mailboxes =INBOX =Box2 =Box3
# passwords
set imap_pass = 'secret'
set smtp_pass = 'secret'
# folder management
set spoolfile = '+INBOX'
set postponed = '+Drafts'
# set to '' for gmail / automatically saved by server
set record = ''
set trash = ''
```

`$NEWSBEUTER` is called by `/etc/newsbeuter.conf`, and should point to a file containing feed URLs (consider your reading list private and yours). You may want to `ln -sf $XDG_RUNTIME_DIR ~/.newsbeuter` or something similar so it doesn't create an empty directory in your home folder.

`$KNIFE_PATH` is called by `/etc/chef/knife.rb`, and should point to the certificate used to authenticate to `$CHEF_SERVER` (string).
