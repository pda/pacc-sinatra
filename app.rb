#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'rfeedparser'

get '/' do
  @subtitle = 'front page'
  @bookmarks = FeedParser.parse('http://feeds.delicious.com/v2/rss/paul.annesley?count=8')
  haml :frontpage
end

helpers do
  def title(title, subtitle)
    @subtitle ? "#{subtitle} — #{title}" : title
  end
end

# TODO: better way to switch HAML to HTML5..?
class Sinatra::Application
  def self.haml; { :format => :html5 }; end
end

