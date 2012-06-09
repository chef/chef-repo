#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "mysql::client"

case node[:platform]
when "debian","ubuntu"

  directory "/var/cache/local/preseeding" do
    owner "root"
    group "root"
    mode 0755
    recursive true
  end

  execute "preseed mysql-server" do
    command "debconf-set-selections /var/cache/local/preseeding/mysql-server.seed"
    action :nothing
  end

  template "/var/cache/local/preseeding/mysql-server.seed" do
    source "mysql-server.seed.erb"
    owner "root"
    group "root"
    mode "0600"
    notifies :run, resources(:execute => "preseed mysql-server"), :immediately
  end
  template "/etc/mysql/debian.cnf" do
    source "debian.cnf.erb"
    owner "root"
    group "root"
    mode "0600"
  end
end

package "mysql-server" do
  action :install
end

service "mysql" do
  service_name value_for_platform([ "centos", "redhat", "suse", "fedora" ] => {"default" => "mysqld"}, "default" => "mysql")
  if (platform?("ubuntu") && node.platform_version.to_f >= 10.04)
    restart_command "restart mysql"
    stop_command "stop mysql"
    start_command "start mysql"
  end
  supports :status => true, :restart => true, :reload => true
  action :nothing
end

template value_for_platform([ "centos", "redhat", "suse" , "fedora" ] => {"default" => "/etc/my.cnf"}, "default" => "/etc/mysql/my.cnf") do
  source "my.cnf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "mysql"), :immediately
end

unless Chef::Config[:solo]
  ruby_block "save node data" do
    block do
      node.save
    end
    action :create
  end
end

# set the root password on platforms 
# that don't support pre-seeding
unless %w{debian ubuntu}.include?(node[:platform])
  execute "assign-root-password" do
    command "/usr/bin/mysqladmin -u root password #{node[:mysql][:server_root_password]}"
    action :run
    only_if "/usr/bin/mysql -u root -e 'show databases;'"
  end
end

grants_path = value_for_platform(
  ["centos", "redhat", "suse", "fedora" ] => {
    "default" => "/etc/mysql_grants.sql"
  },
  "default" => "/etc/mysql/grants.sql"
)

begin
  t = resources(:template => "/etc/mysql/grants.sql")
rescue
  Chef::Log.warn("Could not find previously defined grants.sql resource")
  t = template "/etc/mysql/grants.sql" do
    path grants_path
    source "grants.sql.erb"
    owner "root"
    group "root"
    mode "0600"
    action :create
  end
end

execute "mysql-install-privileges" do
  command "/usr/bin/mysql -u root #{node[:mysql][:server_root_password].empty? ? '' : '-p' }#{node[:mysql][:server_root_password]} < #{grants_path}"
  action :nothing
  subscribes :run, resources(:template => "/etc/mysql/grants.sql"), :immediately
end
