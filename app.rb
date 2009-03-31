#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'rfeedparser'
require 'pacc/tokyotyrant'
require 'pacc/couch'
require 'uri'
require 'time'

set :haml => { :format => :html5 },
  :datastore_url => 'http://localhost:1978/pacc/',
  :couchdb_url => 'http://localhost:5984/pacc',
  :delicious_url => 'http://feeds.delicious.com/v2/rss/paul.annesley?count=8',
  :authored_elsewhere_url => 'http://www.google.com/reader/public/atom/user/01919883411298058200/label/authored',
  :announced_elsewhere_url => 'http://www.google.com/reader/public/atom/user/01919883411298058200/label/annoucement',
  :commented_url => 'http://www.google.com/reader/public/atom/user/01919883411298058200/label/commented'

get '/' do
  cache = Pacc::TokyoTyrantCache.new(options.datastore_url)
  @bookmarks = cache.get 'bookmarks' do
    FeedParser.parse(options.delicious_url)['entries']
  end
  @posts = Pacc::Couch.new(options.couchdb_url).view('blog/posts').rows
  haml :frontpage
end

get '/about' do
  cache = Pacc::TokyoTyrantCache.new(options.datastore_url)
  @bookmarks = cache.get 'bookmarks' do
    FeedParser.parse(options.delicious_url)['entries']
  end
  @authored_elsewhere = cache.get 'authored_elsewhere' do
    FeedParser.parse(options.authored_elsewhere_url)['entries'][0..9]
  end
  @announced_elsewhere = cache.get 'announced_elsewhere' do
    FeedParser.parse(options.announced_elsewhere_url)['entries'][0..9]
  end
  @commented = cache.get 'commented' do
    FeedParser.parse(options.commented_url)['entries'][0..9]
  end
  haml :about
end

helpers do
  def feed_entry_host(entry) URI.parse(entry['link']).host end
  def feed_entry_date(entry) Time.mktime(*entry['updated_parsed'][0..7]).strftime('%d %B %Y') end
end
