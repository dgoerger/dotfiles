unless node['workstation']['corporate']
  if node['workstation']['dnscrypt_providers'].any? or node['workstation']['dns_providers'].any?
    # if NetworkManager isn't starting dnsmasq, we have to
    service 'dnsmasq' do
      supports :status => true, :restart => true
      action [ :enable, :start ]
    end
    template '/etc/dnsmasq.d/settings.conf' do
      source 'dnsmasq.conf.erb'
      owner 'root'
      group 'root'
      mode '0444'
      action :create
      notifies :restart, 'service[dnsmasq]', :delayed
    end
    include_recipe 'workstation::dnscrypt'
  end
else
  # if corporate, delete the dnsmasq conf if it exists
  file '/etc/dnsmasq.d/settings.conf' do
    action :delete
  end
end
service 'NetworkManager' do
  supports :reload => true
  action :nothing
end
template '/etc/NetworkManager/NetworkManager.conf' do
  source 'NetworkManager.conf.erb'
  owner 'root'
  group 'root'
  mode '0444'
  action :create
  notifies :reload, 'service[NetworkManager]', :delayed
end
# dnsblock - blackhole bad stuff
# .. expectation is it should work even if NetworkManager manages dnsmasq
execute 'dnsblock_initialize' do
  command '/usr/local/sbin/dnsblock_updater'
  action :nothing
end
cookbook_file '/usr/local/sbin/dnsblock_updater' do
  source 'dnsblock_updater'
  owner 'root'
  group 'root'
  mode '0554'
  action :create
  notifies :run, 'execute[dnsblock_initialize]', :delayed
end
cron 'dnsblock_update' do
  time :weekly
  user 'root'
  command '/usr/local/sbin/dnsblock_updater'
  action :create
end
