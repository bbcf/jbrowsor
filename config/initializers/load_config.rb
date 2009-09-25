config_file = "#{RAILS_ROOT}/config/config.yml"
if File.exists? config_file
  APP_CONFIG = YAML.load_file(config_file)[RAILS_ENV]
else
  Kernel.warn "Application configuration file \"#{config_file}\" not found!"
end
