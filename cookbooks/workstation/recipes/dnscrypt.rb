if node['workstation']['dnscrypt_providers'].any? and node['workstation']['dnsmasq']
  execute 'dnscrypt_useradd' do
    # create dnscrypt user, use /sbin/nologin
    command 'useradd -r -d /var/dnscrypt -m -s /sbin/nologin dnscrypt'
    action :nothing
  end
  yum_package 'dnscrypt-proxy' do
    action :install
    allow_downgrade false
    notifies :run, 'execute[dnscrypt_useradd]', :immediately
  end

  execute "dnscrypt_killall" do
    # because we're using templates, we have to clean up by killing with a wildcard; a bit gross actually FIXME
    command 'systemctl daemon-reload && systemctl disable dnscrypt-proxy\* && systemctl stop dnscrypt-proxy\*'
    action :nothing
  end
  template '/etc/sysconfig/dnscrypt-proxy.conf' do
    source 'dnscrypt-proxy.conf.erb'
    owner 'root'
    group 'root'
    mode '0444'
    action :create
    notifies :restart, 'execute[dnscrypt_killall]', :immediately
  end
  # <!-- brief interlude when DNS might be totally broken
  cookbook_file '/etc/systemd/system/dnscrypt-proxy@.service' do
    # set systemd service template
    source 'dnscrypt-proxy@.service'
    owner 'root'
    group 'root'
    mode '0444'
    action :create
    notifies :run, 'execute[dnscrypt_killall]', :immediately
  end

  node['workstation']['dnscrypt_providers'].each do |ordinal,_provider|
    service "dnscrypt-proxy@#{ordinal}" do
      supports :restart => true
      action [ :enable, :start ]
    end
  end
  # DNS should be back by now -->
end
