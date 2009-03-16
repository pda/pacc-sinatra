#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'

get '/' do
  @subtitle = 'front page'
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

