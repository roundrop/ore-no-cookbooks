#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2013, roundrop
#

version = node['mysql']['version']
my_cnf_path = '/usr/my.cnf'

bash 'remove_installed_mysql' do
  only_if 'yum list installed | grep mysql*'
  user 'root'

  code <<-EOL
    yum remove -y mysql*
  EOL
end

node['mysql']['install_rpms'].each do |rpm|
  cookbook_file "/tmp/#{rpm[:rpm_file]}" do
    source "#{version}/#{rpm[:rpm_file]}"
  end

  package "#{rpm[:package_name]}" do
    action :install
    provider Chef::Provider::Package::Rpm
    source "/tmp/#{rpm[:rpm_file]}"
  end
end

template "#{my_cnf_path}" do
  user 'root'
  group 'root'
  mode '0644'
  source 'my.cnf.erb'

  variables ({
    :server_charset                  => node['mysql']['server_charset'],
    :max_connections                 => node['mysql']['max_connections'],
    :query_cache_size                => node['mysql']['query_cache_size'],
    :table_cache_size                => node['mysql']['table_cache_size'],
    :thread_cache_size               => node['mysql']['thread_cache_size'],
    :join_buffer_size                => node['mysql']['join_buffer_size'],
    :sort_buffer_size                => node['mysql']['sort_buffer_size'],
    :read_rnd_buffer_size            => node['mysql']['read_rnd_buffer_size'],
    :innodb_file_per_table           => node['mysql']['innodb_file_per_table'],
    :innodb_data_file_path           => node['mysql']['innodb_data_file_path'],
    :innodb_autoextend_increment     => node['mysql']['innodb_autoextend_increment'],
    :innodb_buffer_pool_size         => node['mysql']['innodb_buffer_pool_size'],
    :innodb_additional_mem_pool_size => node['mysql']['innodb_additional_mem_pool_size'],
    :innodb_write_io_threads         => node['mysql']['innodb_write_io_threads'],
    :innodb_read_io_threads          => node['mysql']['innodb_read_io_threads'],
    :innodb_log_buffer_size          => node['mysql']['innodb_log_buffer_size'],
    :innodb_log_file_size            => node['mysql']['innodb_log_file_size'],
    :innodb_flush_log_at_trx_commit  => node['mysql']['innodb_flush_log_at_trx_commit']
  })
end

directory '/var/log/mysql/' do
  mode 0755
  owner "mysql"
  group "mysql"
  action :create
end

service 'mysql' do
  action [ :enable, :start ]
end


root_password = node['mysql']['root_password']

package 'expect' do
  only_if 'ls /root/.mysql_secret'
  :install
end

template '/tmp/password_set.sh' do
  user "root"
  group "root"
  source 'password_set.sh.erb'
  variables ({
    :root_password => root_password
  })
end

execute 'password_set' do
  only_if 'ls /root/.mysql_secret'
	user 'root'
	command 'chmod +x /tmp/password_set.sh && /tmp/password_set.sh && rm -f /tmp/password_set.sh'
end

package 'expect' do
  :remove
end
