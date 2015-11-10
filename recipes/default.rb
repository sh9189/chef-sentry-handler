# Make sure the handlers folder exists
directory node["chef_handler"]["handler_path"] do
  mode "755"
  recursive true
  action :nothing
end.run_action(:create)

chef_gem "uuidtools" do
  compile_time false if Chef::Resource::ChefGem.method_defined?(:compile_time)
end

chef_gem "sentry-raven" do
  version "0.9.4"
  compile_time false if Chef::Resource::ChefGem.method_defined?(:compile_time)
end

handler_file = ::File.join(node["chef_handler"]["handler_path"], 'sentry.rb')

cookbook_file handler_file do
  source "sentry.rb"
  mode "644"
  action :nothing
end.run_action(:create)

chef_handler "Raven::Chef::SentryHandler" do
  source handler_file
  supports({:exception => true})
  arguments [node]
  action :nothing
end.run_action(node['sentry']['enabled'] ? :enable : :disable)
