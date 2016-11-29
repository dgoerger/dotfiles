if node['workstation']['dnscrypt_providers'].any? and node['workstation']['dnsmasq']
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

  execute 'daemon_reload' do
    command 'systemctl daemon-reload'
    action :nothing
  end

  # set primary systemd service file
  template '/etc/systemd/system/dnscrypt-proxy.service' do
    source 'dnscrypt-proxy.service.erb'
    owner 'root'
    group 'root'
    mode '0444'
    action :create
    notifies :run, 'execute[daemon_reload]', :delayed
  end

# TODO uncomment this when it's non-embarrassing to look at
#
#  ### set backup dnscrypt service files if extra are configured
#  # TODO something more elegant than a counter - starts at 2 to match ordinal expectations + RESOLVER_count in dnsmasq.conf
#  count = 2
#  # cleverly iterate over all providers except the first... so that the required number of iterations occurs
#  resolvers_except_first = node['workstation']['dnscrypt_providers'].select{|x| x != node['workstation']['dnscrypt_providers'].first[0]}
#  unless resolvers_except_first.nil?
#    resolvers_except_first.each do |provider,_port|
#      template "/etc/systemd/system/dnscrypt-proxy-#{count}.service" do
#        source 'dnscrypt-proxy-backup.service.erb'
#        owner 'root'
#        group 'root'
#        mode '0444'
#        variables :counts => { provider => count }
#        action :create
#        notifies :run, 'execute[daemon_reload]', :delayed
#      end
#    count += 1
#    end
#  end
  service 'dnscrypt-proxy' do
    supports :status => true, :restart => true
    action [ :enable ]
  end
  template '/etc/sysconfig/dnscrypt-proxy.conf' do
    source 'dnscrypt-proxy.conf.erb'
    owner 'root'
    group 'root'
    mode '0444'
    action :create
    notifies :restart, 'service[dnscrypt-proxy]', :delayed
  end
end
