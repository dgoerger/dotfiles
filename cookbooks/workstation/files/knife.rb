# see: http://docs.getchef.com/config_rb_knife.html

log_level                :info
log_location             STDOUT
node_name                ENV['OPSCODE_USER'] || ENV['USER']
client_key               ENV['KNIFE_PATH']
chef_server_url          ENV['CHEF_SERVER']
ssl_verify_mode          :verify_peer
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.cache/chef-checksums" )
