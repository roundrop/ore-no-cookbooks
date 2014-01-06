group 'nginx' do
  group_name  'nginx'
  gid         777
  action      [:create]
end

user 'nginx' do
  comment   'nginx'
  uid       777
  group     'nginx'
  home      '/var/run/nginx'
  shell     '/bin/false'
  password  nil
  supports  :manage_home => true
  action    [:create, :manage]
end

bash "install_nginx" do
  user "root"
  group "root"
  cwd "/tmp"
  flags "-e"
  code <<-EOH
    rm -rf nginx-1.4.3.tar.gz
    rm -rf nginx-1.4.3
    rm -rf pcre-8.32.tar.gz
    rm -rf pcre-8.32
    wget http://nginx.org/download/nginx-1.4.3.tar.gz
    tar zxf nginx-1.4.3.tar.gz
    wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.32.tar.gz
    tar -xvf pcre-8.32.tar.gz
    cd nginx-1.4.3
    ./configure --prefix=/usr/local --conf-path=/etc/nginx/nginx.conf --user=nginx --group=nginx --with-pcre=/tmp/pcre-8.32
    make
    make install
  EOH
  creates "/usr/local/sbin/nginx"
end

template "nginx.conf" do
  path "/etc/nginx/nginx.conf"
  source "nginx14.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, 'service[nginx]'
end

directory '/var/log/nginx' do
  mode 0755
  owner 'root'
  group 'root'
  recursive true
end

template "/etc/rc.d/init.d/nginx" do
  source 'initd.erb'
  owner "root"
  group "root"
  mode "0755"
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
