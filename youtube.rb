require 'sinatra'
require 'open-uri'
require 'nokogiri'

get '/user/:username' do
  doc = feed params[:username]

  output = ''

  doc.xpath("//a:entry", {"a" => "http://www.w3.org/2005/Atom"}).each do |entry|
    title = entry.xpath("a:title", {"a" => "http://www.w3.org/2005/Atom"}).first
    content = entry.xpath("a:content", {"a" => "http://www.w3.org/2005/Atom"}).first
    video_id = ''
    if /watch\?v=([A-Za-z0-9_-]+)/ =~ content
      video_id = $1
    end
    output << "<div>#{title.text.to_s} <img src='http://#{video_id}' /></div>"
  end

  output
end

def feed(username)
  url = "http://gdata.youtube.com/feeds/base/users/#{username}/newsubscriptionvideos"
  Nokogiri::XML(open(url)) 
end
