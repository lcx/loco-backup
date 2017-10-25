require 'locomotive/coal'
require 'yaml'
require 'fileutils'

config = YAML.load_file('config/config.yml')
client = Locomotive::Coal::Client.new(config['site']['host'], { email: config['site']['email'], api_key: config['site']['api_key'] })
FileUtils.mkdir_p 'logs/'

sites = client.sites.all
total_sites = sites.count
puts "Need to backup #{total_sites} sites"
sites.map(&:handle).each_with_index do |site, ii|
  puts "(#{ii+1}/#{total_sites}) Backing up #{site}"
  backup_name = "#{Time.now.strftime("%Y%m%d-%H%M%S")}-#{site}"
  `wagon backup #{backup_name} #{config['site']['host']} -h #{site} -e #{config['site']['email']} -a #{config['site']['api_key']} > logs/#{backup_name}.log 2>&1`
end
