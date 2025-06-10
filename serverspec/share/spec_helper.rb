require 'serverspec'
require 'net/ssh'

os = ENV['OS']
base_spec_dir = Pathname.new(File.join(File.dirname(__FILE__)))

Dir[base_spec_dir.join("#{os}/*.rb")].sort.each do |f|
  require f unless f.match?(/uom.*\.rb/)
end

if ENV['UOM_USER_ENABLED'].to_s.downcase == 'true'
  Dir[base_spec_dir.join("#{os}/uom*.rb")].each do |uom_file|
    require uom_file
  end
end

set :backend, :ssh

if ENV['ASK_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "highline is not available. Try installing it."
  end
  set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  set :sudo_password, ENV['SUDO_PASSWORD']
end

host = ENV['TARGET_HOST']

options = Net::SSH::Config.for(host)

options[:user] ||= Etc.getlogin
options[:keys] = ENV['KEY']

set :host,        options[:host_name] || host
set :ssh_options, options
