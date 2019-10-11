require 'locomotive/coal'
require 'yaml'
require 'fileutils'
require 'shellwords'

config = YAML.load_file('config/config.yml')
client = Locomotive::Coal::Client.new(config['site']['host'], { email: config['site']['email'], api_key: config['site']['api_key'] })
FileUtils.mkdir_p 'logs/'

sites = client.sites.all
total_sites = sites.count
puts "Need to backup #{total_sites} sites"
sites.map(&:handle).each_with_index do |site, ii|
  puts "(#{ii+1}/#{total_sites}) Backing up #{site}"
  pattern = "\\-[0-9]{6}-#{site}$"
  site_backups = `ls | grep -E #{pattern.shellescape}`.split
  # backup
  last_backup =  site_backups[site_backups.count - 1]
  backup_name = "#{Time.now.strftime("%Y%m%d-%H%M%S")}-#{site}"
  `cp -al "#{last_backup}" "#{backup_name}"`
  `wagon backup #{backup_name} #{config['site']['host']} -h #{site} -e #{config['site']['email']} -a #{config['site']['api_key']} > logs/#{backup_name}.log 2>&1`
  # rotation
  dropped = 0
  while (site_backups.count - dropped > config['site']['retention_days'])
    puts "Dropping old backup #{site_backups[dropped]}"
    drop = `find . -mindepth 1 -maxdepth 1 -type d -name "#{site_backups[dropped]}"| xargs rm -rf &>> logs/#{backup_name}.log`
    dropped += 1
  end
end
