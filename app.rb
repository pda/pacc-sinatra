#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'datastore'

set :haml, :format => :html5

cache = HttpDataStore.new 'http://localhost:1978/pacc/'

get '/' do
  @subtitle = 'front page'
  @bookmarks = cache.get('bookmarks')
  haml :frontpage
end

helpers do
  def title(title, subtitle)
    @subtitle ? "#{subtitle} — #{title}" : title
  end
end
