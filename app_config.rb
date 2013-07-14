class AppConfig
  FILE_CONFIG  = File.exists?('config.yml') ? YAML.load_file(File.open('config.yml'))[ENV['RACK_ENV']]['foursquare'] : {}
  FSQ_API_KEY      = FILE_CONFIG.fetch('api_key', ENV['FSQ_KEY'])
  FSQ_API_SECRET   = FILE_CONFIG.fetch('client_secret', ENV['FSQ_SECRET'])
  FSQ_REDIRECT_URI = FILE_CONFIG.fetch('redirect_uri', ENV['FSQ_REDIRECT_URI'])
end
