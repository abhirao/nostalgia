require 'rest_client'
require_relative '../app_config'

class Notification
  API_KEY = AppConfig::MAILGUN_API_KEY
  API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/#{AppConfig::MAILGUN_API_DOMAIN}"

  def self.process(to, subject, text, html)
    RestClient.post API_URL+"/messages",
      :from => "ev@example.com",
      :to => to,
      :subject => subject,
      :text => text,
      :html => html
  end
end
