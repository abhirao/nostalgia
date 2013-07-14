require 'net/https'
require 'uri'
require 'json'

class FourSquare
  CONFIG       = File.exists?('config.yml') ? YAML.load_file(File.open('config.yml'))[ENV['RACK_ENV']]['foursquare'] : {}
  API_KEY      = CONFIG.fetch('api_key', ENV['FSQ_KEY'])
  API_SECRET   = CONFIG.fetch('client_secret', ENV['FSQ_SECRET'])
  REDIRECT_URI = CONFIG.fetch('redirect_uri', ENV['FSQ_REDIRECT_URI'])
  API_VERSION  = '20130714'
  AUTH_URL     = "https://foursquare.com/oauth2/authenticate?client_id=#{API_KEY}&response_type=code&redirect_uri=#{REDIRECT_URI}"
  TOKEN_URL    = "https://foursquare.com/oauth2/access_token?client_id=#{API_KEY}&client_secret=#{API_SECRET}&grant_type=authorization_code&redirect_uri=#{REDIRECT_URI}&code="
  CHECKINS_URL = "https://api.foursquare.com/v2/users/self/checkins?v=#{API_VERSION}"

  attr_accessor :token

  def self.construct_ssl_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http
  end

  def get_token(code)
    TokenRequester.new.get_token_using_code(code)
  end

  def checkins(page)
    offset = (page -1) * 20 #no need for zero-based indexing
    make_request CHECKINS_URL + "&offset=#{offset}"
  end

  def year_ago
    now = Time.now.to_date.next_day
    before = Time.new(now.year - 1, now.month, now.day).to_date
    after = before.prev_day
    make_request CHECKINS_URL + "&beforeTimestamp=#{before.to_time.to_i}&afterTimestamp=#{after.to_time.to_i}"
  end

  private

  def make_request(url)
    uri = URI.parse(URI.encode(url + "&oauth_token=#{@token}"))
    req = Net::HTTP::Get.new(uri.request_uri)
    JSON.parse(FourSquare.construct_ssl_request(uri).request(req).body)
  end

  class TokenRequester
    def get_token_using_code(code)
      token_uri = URI.parse(URI.encode(TOKEN_URL + "#{code}"))
      auth_request = Net::HTTP::Get.new(token_uri.request_uri)
      response = JSON.parse(FourSquare.construct_ssl_request(token_uri).request(auth_request).body)
      response['access_token']
    end
  end
end
