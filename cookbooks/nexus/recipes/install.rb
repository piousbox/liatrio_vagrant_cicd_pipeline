
#
# Cookbook:   nexus
# Recipe:     install
#
# Author:     piousbox@gmail.com
# Copyright:  2015 Liatrio
#
# This recipe *customly* installs Nexus and enables it as a service.
# For the default installation, include recipe[nexus::default] instead.
#

include_recipe "nexus::_common_system"
include_recipe "java"

user node[:nexus][:user] do
  action :create
end

group node[:nexus][:group] do
  action :create
end

#
# download & unpack
#
execute "download Nexus OSS" do
  command <<-EOL
    wget http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz;
  EOL
  not_if { ::File.exists?('/opt/nexus-latest-bundle.tar.gz') }
  cwd "/opt"
end

execute "unpack Nexus OSS" do
  command <<-EOL
    rm -frv trash; mkdir -p trash; 
    tar --directory trash -xvf nexus-latest-bundle.tar.gz;
  EOL
  cwd "/opt"
end

execute "move Nexus OSS" do
  command "rm -rfv nexus nexus-* ; mv /opt/trash/nexus-* . ; ln -s nexus-* nexus"
  cwd "/usr/local"
end

#
# configure
#
%w(
  /usr/local/nexus/shared/pids
  /usr/local/nexus/bin/jsw/linux-x86-64
  /usr/local/nexus/logs
  /usr/local/nexus/tmp
  /usr/local/sonatype-work
).each do |dir|
  directory dir do
    action :create
    recursive true
    user node[:nexus][:user]
    group node[:nexus][:group]
    mode '0777'
  end
end

# configure nexus as a service
template "/etc/init.d/nexus" do
  source "usr/local/nexus/bin/nexus.erb"
  owner node[:nexus][:user]
  group node[:nexus][:group]
  mode "0744"
  variables({
    :nexus_home   => node[:nexus][:home],
    :nexus_user   => node[:nexus][:user],
    :nexus_piddir => node[:nexus][:pid_dir]
  })
end

case node['platform']
when 'debian', 'ubuntu'
  execute "update_rcd" do
    command "update-rc.d nexus defaults"
    cwd "/etc/init.d"
  end
when 'redhat', 'fedora', 'centos'
  execute "update_chkconfig" do
    command "chkconfig --add nexus && chkconfig --levels 345 nexus on"
    cwd "/etc/init.d"
  end
end

service 'nexus' do
  action [ :enable, :start ]
end

# set NEXUS_HOME ?
# export NEXUS_HOME=/usr/local/nexus

