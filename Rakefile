require 'mongoid'
require_relative 'models/user'
require_relative 'lib/notification'
require_relative 'lib/foursquare'
require 'haml'

task :environment do
  Mongoid.load!('mongoid.yml')
end

task :notify => [:environment] do
  User.all.each do |user|
    foursquare= FourSquare.new
    foursquare.token = user.token
    checkins = foursquare.year_ago['response']['checkins']['items'].sort_by!{|c| c['createdAt']}
    engine = Haml::Engine.new(File.read('mails/plaintext.haml'))
    text_body = engine.render(Object.new, checkins: checkins)
    engine = Haml::Engine.new(File.read('mails/richtext.html.haml'))
    html_body = engine.render(Object.new, checkins: checkins)
    Notification.process(user.email, 'Your checkins a year ago', text_body, html_body)
  end
end
