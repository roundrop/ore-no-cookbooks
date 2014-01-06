#
# Cookbook Name:: php
# Recipe:: php-fpm
#
# Copyright 2013, roundrop
#

version = node['php']['version']
php_path = "/usr/local/phpenv/versions/#{version}/"
php_fpm_conf_path = "/usr/local/phpenv/versions/#{version}/etc/php-fpm.conf"
php_fpm_bin_path = "/usr/local/phpenv/versions/#{version}/sbin/php-fpm"

template "#{php_fpm_conf_path}" do
  owner 'root'
  group 'root'
  mode '0644'
  source 'php-fpm.conf.erb'

  variables ({
    :version => version,
    :listen => node['php-fpm']['listen'],
    :user   => node['php-fpm']['user'],
    :group  => node['php-fpm']['group']
  })
end

template "/etc/init.d/php-fpm" do
  owner 'root'
  group 'root'
  mode '0744'
  source 'php-fpm.erb'

  variables ({
    :bin  => php_fpm_bin_path,
    :conf => php_fpm_conf_path
  })
end

directory "#{php_path}www" do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

service 'php-fpm' do
  only_if 'ls /etc/init.d/php-fpm'
  action [ :enable, :restart ]
end
