#
# Cookbook Name:: artifact_test
# Recipe:: nexus_config
#
# Author:: Kyle Allan (<kallan@riotgames.com>)
# 
# Copyright 2013, Riot Games
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

group "artifact"
user "artifacts"

nexus_configuration = Chef::Artifact::NexusConfiguration.new(
  node[:artifact_test][:other_nexus][:url], node[:artifact_test][:other_nexus][:repository],
  node[:artifact_test][:other_nexus][:username], node[:artifact_test][:other_nexus][:url][:password]
)

artifact_deploy "artifact_test" do
  version node[:artifact_test][:version]
  artifact_location node[:artifact_test][:location]
  artifact_checksum node[:artifact_test][:checksum]
  nexus_configuration nexus_configuration
  deploy_to node[:artifact_test][:deploy_to]
  owner "artifacts"
  group "artifact"

  action :deploy
end