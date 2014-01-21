include_recipe "ntp"

# !!!NOTE that this setting is specialized for Japan!!!
bash 'set_timezone_to_japan' do
  not_if 'date | grep JST'
  user 'root'

  code <<-EOL
    cp -p /usr/share/zoneinfo/Japan /etc/localtime
    ntpdate ntp.nict.jp
    /etc/rc.d/init.d/ntpd restart
  EOL
end

bash 'increase_max_#_of_file_descriptors' do
  not_if 'ulimit -n | grep 65536'
  user 'root'

  code <<-EOL
    echo "\" >> /etc/security/limits.conf
    echo "root soft nofile 65536" >> /etc/security/limits.conf
    echo "root hard nofile 65536" >> /etc/security/limits.conf
    echo "* soft nofile 65536" >> /etc/security/limits.conf
    echo "* hard nofile 65536" >> /etc/security/limits.conf
  EOL
end

bash 'optimize_network_kernel_parameters' do
  not_if 'cat /etc/sysctl.conf | grep tcp_tw_recycle'
  user 'root'

  code <<-EOL
    echo "\n" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
    echo "net.ipv4.ip_local_port_range = 10240    65535" >> /etc/sysctl.conf
  EOL
end

include_recipe "td_agent"

