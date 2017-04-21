# ensure the packages we need for what follows are installed
node['workstation']['packages'].each do |package|
  dnf_package package do
    action :install
  end
end

# define this in case needed - systemd
execute 'daemon_reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

# firewall
service 'firewalld' do
  # use restart instead of reload
  # NB: 'reload' will kill the NIC when creating/destroying firewall XML files
  # ... 'restart' does not have this limitation
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
file '/usr/lib/firewalld/zones/FedoraServer.xml' do
  # see rhbz#1171114
  action :delete
  notifies :restart, 'service[firewalld]', :delayed
end

# set system-wide crypto policy
execute 'update-crypto-policies' do
  command 'update-crypto-policies'
  action :nothing
end
file '/etc/crypto-policies/config' do
  content node['workstation']['crypto-policy']
  owner 'root'
  group 'root'
  mode '0444'
  action :create
  notifies :run, 'execute[update-crypto-policies]', :immediately
end

# DNS
if node['workstation']['dnsmasq']
  include_recipe 'workstation::dnsmasq'
end

# powertop
service 'powertop' do
  action [ :enable, :start ]
end

# logging
service 'rsyslog' do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
cookbook_file '/etc/rsyslog.conf' do
  source 'rsyslog.conf'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
  notifies :restart, 'service[rsyslog]', :delayed
end
service 'systemd-journald' do
  supports :restart => true
  action [ :enable, :start ]
end
cookbook_file '/etc/systemd/journald.conf' do
  source 'journald.conf'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
  notifies :restart, 'service[systemd-journald]', :delayed
end

# ntp
service 'chronyd' do
  action [ :enable, :start ]
end

# ssh-agent as a service
execute 'ssh-agent_enable' do
  command 'ln -sf /dev/null /etc/xdg/autostart/gnome-keyring-ssh.desktop && systemctl --global enable ssh-agent'
  action :nothing
end
cookbook_file '/etc/systemd/user/ssh-agent.service' do
  source 'ssh-agent.service'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
  notifies :run, 'execute[ssh-agent_enable]', :delayed
end

# system-wide userland defaults
cookbook_file '/etc/profile.d/custom_aliases.sh' do
  source 'aliases.sh'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
cookbook_file '/etc/vimrc' do
  source 'vimrc'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
cookbook_file '/etc/vimrc.local' do
  source 'vimrc.local'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
cookbook_file '/etc/gitconfig' do
  source 'gitconfig'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
cookbook_file '/etc/lynx-site.cfg' do
  source 'lynx.cfg'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
cookbook_file '/etc/sudoers.d/umask' do
  source 'sudoers_umask'
  owner 'root'
  group 'root'
  mode '0440'
  action :create
end
cookbook_file '/etc/tmux.conf' do
  source 'tmux.conf'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
directory '/etc/gnupg' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
cookbook_file '/etc/gnupg/gpgconf.conf' do
  source 'gpgconf.conf'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
service 'sshd' do
  supports :restart => true
  action :nothing
end
cookbook_file '/etc/ssh/sshd_config' do
  source 'sshd_config'
  owner 'root'
  group 'root'
  mode '0400'
  action :create
  notifies :restart, 'service[sshd]', :delayed if File.exist?('/etc/systemd/system/multi-user.target.wants/sshd.service')
end
cookbook_file '/etc/ssh/ssh_config' do
  source 'ssh_config'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
cookbook_file '/etc/Muttrc.local' do
  source 'muttrc'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
cookbook_file '/etc/mailcap' do
  source 'mailcap'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
cookbook_file '/etc/systemd/logind.conf' do
  source 'logind.conf'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
directory '/etc/gtk-3.0' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
cookbook_file '/etc/gtk-3.0/settings.ini' do
  source 'gtk3.ini'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
cookbook_file '/etc/newsbeuter.conf' do
  source 'newsbeuter.conf'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
link '/etc/systemd/system/rpcbind.service' do
  # disable listening on port 111, takes effect on next reboot
  link_type :symbolic
  to '/dev/null'
  action :create
end
file '/etc/cron.allow' do
  content 'root'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
template '/etc/logrotate.d/chake' do
  source 'logrotate.conf.erb'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end

# TeX Live
node['workstation']['texlive'].each do |pkg|
  dnf_package pkg do
    action :install
    only_if node['workstation']['latex']
  end
end

# rkhunter
cron 'rkhunter' do
  time :daily
  user 'root'
  command '/usr/bin/rkhunter --update; /usr/bin/rkhunter --cronjob'
  action :create
end

# patch schedule
cookbook_file '/usr/local/sbin/dnf-patch-everything' do
  source 'dnf-patch-everything'
  owner 'root'
  group 'root'
  mode '0744'
  action :create
end
cron 'dnf-patch-everything' do
  time :daily
  user 'root'
  command '/usr/local/sbin/dnf-patch-everything'
  action :create
end
cron 'chake-policy-updates' do
  time :hourly
  user 'root'
  command 'cd /var/chake && git pull && rake converge'
end

# automatic backup
if File.exist?('/usr/bin/duplicity')
  # assume that installation of duplicity implies intent
  cookbook_file '/usr/local/sbin/duplicity-backup' do
    source 'duplicity_backup'
    owner 'root'
    group 'root'
    mode '0550'
    action :create
  end
  cron 'duplicity-backup' do
    time :daily
    user 'root'
    command '/usr/local/sbin/duplicity-backup'
  end
end

# dorky DCIM import script - could def be improved
cookbook_file '/usr/local/bin/photo_import' do
  source 'photo_import.sh'
  owner 'root'
  group 'root'
  mode '0445'
  action :create
end


### only if a graphical install
if File.exist?('/etc/systemd/system/display-manager.service')
  node['workstation']['graphical_apps'].each do |pkg|
    dnf_package pkg do
      action :install
    end
  end
  # firefox defaults
  cookbook_file '/etc/firefox/pref/user.js' do
    source 'firefox.js'
    owner 'root'
    group 'root'
    mode '0444'
    action :create
  end
  # dconf
  execute 'reload_dconf' do
    command 'dconf update'
    action :nothing
  end
  directory '/etc/dconf/db/gdm.d' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
  directory '/etc/dconf/db/site.d' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
  directory '/etc/dconf/profile' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
  cookbook_file '/etc/dconf/profile/gdm' do
    # enable management of the GDM login screen
    source 'dconf_gdm_profile'
    owner 'root'
    group 'root'
    mode '0444'
    action :create
    notifies :run, 'execute[reload_dconf]', :delayed
  end
  cookbook_file '/etc/dconf/db/gdm.d/01-custom' do
    # copy in gdm settings
    source 'dconf_gdm.ini'
    owner 'root'
    group 'root'
    mode '0444'
    action :create
    notifies :run, 'execute[reload_dconf]', :delayed
  end
  cookbook_file '/etc/dconf/profile/user' do
    # enable management of userland
    source 'dconf_user_profile'
    owner 'root'
    group 'root'
    mode '0444'
    action :create
    notifies :run, 'execute[reload_dconf]', :delayed
  end
  cookbook_file '/etc/dconf/db/site.d/01-custom' do
    # copy in userland settings
    source 'dconf_user.ini'
    owner 'root'
    group 'root'
    mode '0444'
    action :create
    notifies :run, 'execute[reload_dconf]', :delayed
  end
  # work around setting umask to 027
  file '/etc/dconf/db/gdm' do
    mode '0644'
  end
  file '/etc/dconf/db/site' do
    mode '0644'
  end
end
