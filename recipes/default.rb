#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2013, Myles Carrick
#
#

ruby_version = '2.0.0-p247'
ruby_version_concat = ruby_version.gsub(/-/,'')

# Prereqs without which we can't get off the ground
%w(build-essential wget libyaml-dev zlib1g-dev libssl-dev libreadline6-dev libxml2-dev).each do |dep|
  package dep
end

bash "ruby from source" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget http://ftp.ruby-lang.org/pub/ruby/2.0/ruby-#{ruby_version}.tar.gz
  tar -xzf ruby-#{ruby_version}.tar.gz
  cd ruby-#{ruby_version} && ./configure --prefix=/usr/local && make && sudo make install
  EOH
  not_if "ruby -v | grep #{ruby_version_concat}"
end

# Gem prereqs - might need reloading if we picked up new ruby/rubygems
gems = { :rake => '10.1.0',
         :bundler => '1.3.5' }

gems.each do |gem, gem_version|
  gem_package gem do
    action :install
    version gem_version
  end
end

# http://tickets.opscode.com/browse/CHEF-3933
gem_package 'chef' do
  action :install
  options(:prerelease => true)
end
