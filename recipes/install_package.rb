#
# Cookbook Name:: haproxy
# Recipe:: install_package
#
# Copyright 2009, Opscode, Inc.
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

package "haproxy" do
  version node['haproxy']['package']['version'] if node['haproxy']['package']['version']
end

if node.platform == "freebsd"
  group node['haproxy']['group'] do
    system true
  end

  user node['haproxy']['user'] do
    group node['haproxy']['group']
    system true
  end

  template '/usr/local/etc/haproxy.conf' do
    source 'haproxy-initial.conf.erb'
  end
end

directory node['haproxy']['conf_dir'] do
  recursive true
end

directory File.dirname(node['haproxy']['defaults_file']) do
  recursive true
end

template "/etc/init.d/haproxy" do
  source "haproxy-init.erb"
  owner node['root_user']
  group node['root_group']
  mode 00755
  variables(
    :hostname => node['hostname'],
    :conf_dir => node['haproxy']['conf_dir'],
    :prefix => "/usr"
  )
  not_if { node.platform == 'freebsd' }
end

service "haproxy" do
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end
