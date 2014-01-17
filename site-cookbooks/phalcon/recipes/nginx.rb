#
# Cookbook Name:: phalcon
# Recipe:: nginx
#
# Copyright 2013, roundrop
#

nginx_conf_path = node['phalcon']['nginx_conf_path']
document_root_path = node['phalcon']['document_root']

pj_name = node['phalcon']['project_name']
pj_dir  = node['phalcon']['project_dir']
pj_type = node['phalcon']['project_type']

pj_conf_path = begin
  case pj_type
    when 'micro'  ; "#{pj_dir}#{pj_name}/config/config.php"
    when 'simple' ; "#{pj_dir}#{pj_name}/app/config/config.php"
    when 'modules'; "#{pj_dir}#{pj_name}/apps/frontend/config/config.php"
  end
end

template "#{nginx_conf_path}phalcon.conf" do
  owner 'root'
  group 'root'
  mode '0644'
  source 'phalcon_nginx.conf.erb'

  variables ({
    :listen        => node['phalcon']['listen'],
    :server_name   => node['phalcon']['server_name'],
    :document_root => node['phalcon']['document_root'],
    :cgi_pass      => node['phalcon']['cgi_pass'],
    :use_ssl       => node['phalcon']['use_ssl'],
    :crt_file      => node['phalcon']['crt_file'],
    :key_file      => node['phalcon']['key_file']
  })
end

%w{default.conf example_ssl.conf}.each do |conf_file|
  file "/etc/nginx/conf.d/#{conf_file}" do
    action :delete
  end
end

bash 'make_project' do
  not_if "ls #{node['phalcon']['document_root']}"
  user 'root'

  code <<-EOL
    source /etc/profile.d/rbenv.sh
    cd #{pj_dir}
    #phalcon project #{pj_name} --type=#{pj_type} --enable-webtools
    phalcon project #{pj_name} --type=#{pj_type}
    chown -R #{node['phalcon']['nginx_user']}:#{node['phalcon']['nginx_group']} #{node['phalcon']['project_name']}
  EOL
end

template "#{pj_conf_path}" do
  mode '0644'
  source "pj-#{pj_type}_config.php.erb"

  variables ({
    :db_host     => node['phalcon']['db_host'],
    :db_user     => node['phalcon']['db_user'],
    :db_password => node['phalcon']['db_password'],
    :db_name     => node['phalcon']['db_name'],
    :base_uri    => node['phalcon']['base_uri']
  })
end

template "#{node['phalcon']['document_root']}/webtools.config.php" do
  mode '0644'
  source 'webtools.config.php.erb'

  variables ({
    :admin_ip => node['phalcon']['admin_ip']
  })
end

%w{nginx php-fpm}.each do |service_name|
  service "#{service_name}" do
    action [ :enable, :restart ]
  end
end
