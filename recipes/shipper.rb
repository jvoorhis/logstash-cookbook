# Author:: Anthony Goddard
# Author:: Phil Cryer
#
# Cookbook Name:: logstash
# Recipe:: shipper
#
#
# Copyright 2011, Woods Hole Marine Biologcal Laboratory
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

include_recipe 'logstash::default'


#find the broker to send the logs to
broker_host = []
search(:node, "role:#{node['logstash']['broker_role']} AND chef_environment:#{node.chef_environment}") do |n|
  broker_host << n['ipaddress']
end


template "/etc/init.d/logstash" do
  source "logstash.init.erb"
  mode "0755"
end


template "/etc/logstash/shipper.conf" do
  source "shipper.conf.erb"
  variables(
    :broker_host => broker_host,
    :syslog_server => node['logstash']['syslog_server'],
    :files => node['logstash']['files'],
    :syslog => node['logstash']['syslog']
  )
end

service "logstash" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end


