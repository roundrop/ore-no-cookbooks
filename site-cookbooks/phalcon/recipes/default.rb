#
# Cookbook Name:: phalcon
# Recipe:: default
#
# Copyright 2013, roundrop
#

include_recipe "php::default"

install_dir = '/usr/local/src/'
php_version = node['php']['version']
php_conf_path = "/usr/local/phpenv/versions/#{php_version}/etc/conf.d/"

%w{libtool gcc}.each do |package_name|
  package "#{package_name}" do
    :install
  end
end

git "#{install_dir}cphalcon" do
  repository 'git://github.com/phalcon/cphalcon.git'
  action :sync
  user 'root'
end

bash 'install_phalcon' do
  not_if "ls #{php_conf_path}phalcon.ini"
  user 'root'

  code <<-EOL
    source /etc/profile.d/rbenv.sh
    cd #{install_dir}cphalcon/build
    ./install
    echo "extension=phalcon.so" > #{php_conf_path}phalcon.ini
  EOL
end

bash 'install_composer' do
  not_if 'ls /usr/local/phalcon_devtools/composer.phar'
  user 'root'

  code <<-EOL
    source /etc/profile.d/rbenv.sh
    mkdir /usr/local/phalcon_devtools && cd /usr/local/phalcon_devtools
    curl -s http://getcomposer.org/installer | php
  EOL
end

template '/usr/local/phalcon_devtools/composer.json' do
  owner 'root'
  group 'root'
  mode '0644'
  source 'composer.json.erb'
  variables ({:version => node['phalcon']['devtools_version']})
end

bash 'install_phalcon_devtools' do
  not_if 'ls /usr/bin/phalcon'
  user 'root'

  code <<-EOL
    source /etc/profile.d/rbenv.sh
    cd /usr/local/phalcon_devtools
    php composer.phar install
    ln -s /usr/local/phalcon_devtools/vendor/phalcon/devtools/phalcon.php /usr/bin/phalcon
    chmod ugo+x /usr/bin/phalcon
  EOL
end
