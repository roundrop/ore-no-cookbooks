#
# Cookbook Name:: ruby
# Recipe:: rbenv
#
# Copyright 2013, roundrop
#
# All rights reserved - Do Not Redistribute
#
git "/usr/local/rbenv" do
  repository "git://github.com/sstephenson/rbenv.git"
  reference "master"
  action :checkout
  user "root"
  group "root"
end

directory "/usr/local/rbenv/plugins" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

template "/etc/profile.d/rbenv.sh" do
  not_if 'ls /etc/profile.d/rbenv.sh'
  source "rbenv.sh.erb"
  owner "root"
  group "root"
  mode 0644
end

git "/usr/local/rbenv/plugins/ruby-build" do
  repository "git://github.com/sstephenson/ruby-build.git"
  reference "master"
  action :checkout
  user "root"
  group "root"
end

execute "install ruby" do
  not_if "source /etc/profile.d/rbenv.sh; rbenv versions | grep #{node.version}"
  command "source /etc/profile.d/rbenv.sh; rbenv install #{node.version}"
  action :run
end

execute "set global" do
  command "source /etc/profile.d/rbenv.sh; rbenv global #{node.version}; rbenv rehash"
  action :run
end
