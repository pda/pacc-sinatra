#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'rfeedparser'
require 'pacc/tokyotyrant'

set :haml => { :format => :html5 },
  :datastore_url => 'http://localhost:1978/pacc/',
  :couchdb_url => 'http://localhost:5984/pacc',
  :delicious_url => 'http://feeds.delicious.com/v2/rss/paul.annesley?count=8'

get '/' do
  cache = Pacc::TokyoTyrantCache.new(options.datastore_url)
  @bookmarks = cache.get 'bookmarks' do
    FeedParser.parse(options.delicious_url)['entries']
  end
  haml :frontpage
end
