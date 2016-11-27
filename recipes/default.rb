# firewall
yum_package 'firewalld' do
  action :install
  allow_downgrade false
end
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
end

# set system-wide crypto policy
execute 'update-crypto-policies' do
  command 'update-crypto-policies'
  action :nothing
end
file '/etc/crypto-policies/config' do
  content 'FUTURE'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
  notifies :run, 'execute[update-crypto-policies]', :immediately
end

### DNS
# dnscrypt
execute 'dnscrypt_useradd' do
  # force the dnscrypt user to use /sbin/nologin
  command 'useradd -r -d /var/dnscrypt -m -s /sbin/nologin dnscrypt'
  action :nothing
end
yum_package 'dnscrypt-proxy' do
  action :install
  allow_downgrade false
  notifies :run, 'execute[dnscrypt_useradd]', :immediately
end
cookbook_file '/etc/systemd/system/dnscrypt-proxy.service' do
  # primary DNS resolver - IPv4
  source 'dnscrypt-proxy.service'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
cookbook_file '/etc/systemd/system/dnscrypt-proxy-secondary.service' do
  # backup DNS resolver - IPv4
  source 'dnscrypt-proxy-secondary.service'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
cookbook_file '/etc/systemd/system/dnscrypt-proxy-tertiary.service' do
  # IPv6 resolver
  # TODO: graceful failure when uplink doesn't support IPv6
  source 'dnscrypt-proxy-tertiary.service'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
end
service 'dnscrypt-proxy' do
  supports :status => true, :restart => true
  action [ :enable ]
end
cookbook_file '/etc/sysconfig/dnscrypt-proxy.conf' do
  source 'dnscrypt-proxy.conf'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
  notifies :restart, 'service[dnscrypt-proxy]', :delayed
end
# dnsmasq
yum_package 'dnsmasq' do
  action :install
  allow_downgrade false
end
service 'dnsmasq' do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
cookbook_file '/etc/dnsmasq.d/settings.conf' do
  source 'dnsmasq-settings.conf'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
  notifies :restart, 'service[dnsmasq]', :delayed
end
service 'NetworkManager' do
  supports :reload => true
  action :nothing
end
cookbook_file '/etc/NetworkManager/NetworkManager.conf' do
  # NetworkManager shouldn't touch /etc/resolv.conf
  source 'NetworkManager.conf'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
  notifies :reload, 'service[NetworkManager]', :delayed
end
# dnsblock - blackhole stuff
execute 'dnsblock_initialize' do
  command '/usr/local/bin/dnsblock_updater'
  action :nothing
end
cookbook_file '/usr/local/bin/dnsblock_updater' do
  source 'dnsblock_updater'
  owner 'root'
  group 'root'
  mode '0550'
  action :create
  notifies :run, 'execute[dnsblock_initialize]', :delayed
end
cron 'dnsblock_update' do
  minute 59
  hour 18
  weekday 5
  user 'root'
  command '/usr/local/bin/dnsblock_updater'
  action :create
end

# powertop
yum_package 'powertop' do
  action :install
end
service 'powertop' do
  action [ :enable, :start ]
end

node['workstation']['packages'].each do |package|
  yum_package package do
    action :install
    allow_downgrade false
  end
end

# logging
yum_package 'rsyslog' do
  action :install
end
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
yum_package 'chrony' do
  action :install
  allow_downgrade false
end
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
cookbook_file '/etc/gitconfig' do
  source 'gitconfig'
  owner 'root'
  group 'root'
  mode '0444'
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
cookbook_file '/etc/ssh/sshd_config' do
  source 'sshd_config'
  owner 'root'
  group 'root'
  mode '0400'
  action :create
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

# TeX Live
node['workstation']['texlive'].each do |pkg|
  package pkg do
    action :install
  end
end

# tuned for performance
yum_package 'tuned' do
  action :install
end
service 'tuned' do
  supports :restart => true
  action [ :enable, :start ]
end
file '/etc/tuned/active_profile' do
  content 'throughput-performance'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
  notifies :restart, 'service[tuned]', :delayed
end

# rkhunter
cron 'rkhunter' do
  minute 59
  hour 11
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
  minute 30
  hour 18
  user 'root'
  command '/usr/local/sbin/dnf-patch-everything'
  action :create
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
    package pkg do
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
end
