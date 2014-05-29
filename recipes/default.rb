#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2013, Myles Carrick
#
#
ruby_version_concat = node[:ruby][:version].gsub(/-/,'')

# Prereqs without which we can't get off the ground
%w(build-essential wget libyaml-dev zlib1g-dev libssl-dev libreadline6-dev libxml2-dev).each do |dep|
  package dep
end

bash "ruby from source" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-#{node[:ruby][:version]}.tar.gz
  tar -xzf ruby-#{ruby_version}.tar.gz
  cd ruby-#{ruby_version} && ./configure --prefix=/usr/local && make && sudo make install
  EOH
  not_if "ruby -v | grep #{ruby_version_concat}"
end

# Gem prereqs - might need reloading if we picked up new ruby/rubygems
# skip chef for now as its a little funky on the EC2 boxes
gems = { # 'chef' => '11.8.2',
         'bundler' => '1.5.3' }

gems.each do |gem, gem_version|
  gem_package gem do
    action :install
    version gem_version
  end
end
