#
# Cookbook Name:: php
# Recipe:: default
#
# Copyright 2013, roundrop
#

include_recipe "ruby::rbenv"

version = node['php']['version']

node['php']['packages'].each do |package_name|
  package "#{package_name}" do
    :install
  end
end

bash 'install_phpenv' do
  not_if 'ls /usr/local/phpenv/bin/phpenv'
  user 'root'

  code <<-EOL
    rm -rf /usr/local/phpenv
    curl https://raw.githubusercontent.com/CHH/phpenv/master/bin/phpenv-install.sh | sh
    mv -f ~/.phpenv /usr/local/phpenv
    chmod 775 -R /usr/local/phpenv
    echo 'export PHPENV_ROOT="/usr/local/phpenv"' >> /etc/profile.d/rbenv.sh.tmp
    echo 'export PATH="$PHPENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh.tmp
    echo 'eval "$(phpenv init -)"' >> /etc/profile.d/rbenv.sh.tmp
    cat /etc/profile.d/rbenv.sh >> /etc/profile.d/rbenv.sh.tmp
    mv /etc/profile.d/rbenv.sh /etc/profile.d/rbenv.sh.org
    mv /etc/profile.d/rbenv.sh.tmp /etc/profile.d/rbenv.sh
    source /etc/profile.d/rbenv.sh
    mkdir -p /usr/local/phpenv/plugins
  EOL
end

git '/usr/local/phpenv/plugins/php-build' do
  repository 'git://github.com/CHH/php-build.git'
  reference 'master'
  action :sync
  user 'root'
end

cookbook_file '/usr/local/phpenv/plugins/php-build/share/php-build/default_configure_options' do
  not_if "cat /usr/local/phpenv/version | grep #{version}"
  owner 'root'
  group 'root'
  mode '0644'
  source 'default_configure_options'
end

bash 'install_php' do
  not_if "cat /usr/local/phpenv/version | grep #{version}"
  user 'root'

  code <<-EOL
    source /etc/profile.d/rbenv.sh
    phpenv install #{version}
    phpenv rehash
    phpenv global #{version}
  EOL
end
