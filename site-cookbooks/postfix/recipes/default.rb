#
# Cookbook Name:: postfix
# Recipe:: default
#
# Copyright 2013, roundrop
#
# All rights reserved - Do Not Redistribute
#

#include_recipe 'mysql'

bash 'remove_installed_postfix' do
  only_if 'yum list installed | grep postfix*'
  user 'root'

  code <<-EOL
    yum remove -y postfix*
  EOL
end

node['mysql']['install_rpms'].each do |rpm|
  cookbook_file "/tmp/#{rpm[:rpm_file]}" do
    source "MySQL-shared-compat-5.6.12-1.linux_glibc2.5.x86_64.rpm"
  end

  package "#{rpm[:package_name]}" do
    action :install
    provider Chef::Provider::Package::Rpm
    source "/tmp/#{rpm[:rpm_file]}"
  end
end

package 'postfix' do
  :install
end

service 'postfix' do
  action [ :enable, :start ]
end
