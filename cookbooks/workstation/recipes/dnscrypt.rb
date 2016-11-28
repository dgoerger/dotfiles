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
