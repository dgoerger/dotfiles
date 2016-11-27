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

***FORK THIS REPO IF YOU INTEND TO MAKE CHANGES. CHAKE SETS UP A CRON GIT-PULL---DON'T LOCK YOURSELF TO MY REPO UNLESS YOU INTEND TO ACCEPT MY OPINIONATED CODE. YOU HAVE BEEN WARNED.***

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

  1. copy in MUTTRC and NEWSBEUTER secrets, and declare them in `~/.bashrc
  2. if didn't already fork, edit the attributes file(s) in `/var/chake/cookbooks/workstation/attributes/`
  3. seriously though fork this repo and commit your deltas
  4. as root, `cd /var/chake && rake converge`
