class AppConfig
  FSQ_CONFIG  = File.exists?('config.yml') ? YAML.load_file(File.open('config.yml'))['foursquare'] : {}
  MAILGUN_CONFIG  = File.exists?('config.yml') ? YAML.load_file(File.open('config.yml'))['mailgun'] : {}
  FSQ_API_KEY      = FSQ_CONFIG.fetch('api_key', ENV['FSQ_KEY'])
  FSQ_API_SECRET   = FSQ_CONFIG.fetch('client_secret', ENV['FSQ_SECRET'])
  FSQ_REDIRECT_URI = FSQ_CONFIG.fetch('redirect_uri', ENV['FSQ_REDIRECT_URI'])
  MAILGUN_API_KEY  = MAILGUN_CONFIG.fetch('api_key', ENV['MAILGUN_API_KEY'])
end
