#
# Cookbook Name:: rvm
# Recipe:: default
#
# Copyright 2010, 2011, Fletcher Nichol
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

# the installed gpg binary is having issues with downloading the signing key for rvm.
# install gpg2 instead.
package "gnupg2" do
  action :nothing
end.run_action(:install)

bash "import RVM pub key" do
  code <<-GPG
    attempts=1
    max_attempts=4
    keyserver="keys.gnupg.net"

    until [[ $attempts -eq $max_attempts ]]
    do
      echo "gpg attempt ${attempts} for ${keyserver}"

      gpg --verbose --keyserver "hkp://${keyserver}" --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB·

      [[ $? -eq 0 ]] && break
      let "attempts+=1"

      if [[ $attempts -eq 4 ]]
      then
        attempts=1
        keyserver="keyserver.cns.vt.edu"
      fi
    done
    GPG
  user "root"
  action :nothing
end.run_action(:run)

# install rvm api gem during chef compile phase
gem_package 'rvm' do
  action :nothing
end.run_action(:install)

chef_gem 'rvm' do
  action :nothing
end.run_action(:install)

require 'rubygems'
Gem.clear_paths
require 'rvm'
create_rvm_shell_chef_wrapper
create_rvm_chef_user_environment

class Chef::Resource
  # mix in #rvm_cmd_wrap helper into resources
  include Chef::RVM::ShellHelpers
end

class Chef::Recipe
  # mix in recipe helpers
  include Chef::RVM::RecipeHelpers
  include Chef::RVM::StringHelpers
end
