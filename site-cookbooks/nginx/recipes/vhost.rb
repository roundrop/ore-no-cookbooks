# nginx.conf
directory '/etc/nginx/vhost.d/' do
  mode 0755
  owner "root"
  group "root"
  recursive true
end

=begin
template '/etc/nginx/vhost.d/example.com.conf' do
  source 'vhost/example.com.conf.erb'
  variables(
    :nginx_port  => node[:nginx][:port],
  )
end
=end