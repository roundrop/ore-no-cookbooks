script "grant all privileges" do
  not_if { `/usr/bin/mysql -u root -D test -r -B -N -e \"SELECT COUNT(*) FROM mysql.user WHERE user='root' and host = '%'"`.to_i == 1 }
  interpreter "bash"
  user "root"
  code <<-EOL
    /usr/bin/mysql -u root <<CMD
      grant all privileges on test.* to root@"%";
      flush privileges;
CMD
  EOL
end
