require 'sinatra'
require 'open-uri'
require 'nokogiri'

get '/user/:username' do
  doc = feed params[:username]

  videos = Video.parse_from_feed(doc)

  erb :index, :locals => { :videos => videos }
end

def feed(username)
  url = "http://gdata.youtube.com/feeds/base/users/#{username}/newsubscriptionvideos"
  Nokogiri::XML(open(url)) 
end

class Video

  attr_accessor :title, :video_id

  def self.parse_from_feed(doc)
    videos = Array.new 

    doc.xpath("//a:entry", {"a" => "http://www.w3.org/2005/Atom"}).each do |entry|
      videos << Video.new(entry)
    end

    videos
  end

  def initialize(node)
    @title = atom_xpath(node, "title").first.text.to_s
    
    content = atom_xpath(node, "content").first 
    @video_id = $1 if /watch\?v=([A-Za-z0-9_-]+)/ =~ content
  end

  private

  def atom_xpath(entry, name)
    entry.xpath("a:#{name}", {"a" => "http://www.w3.org/2005/Atom"})
  end

end

