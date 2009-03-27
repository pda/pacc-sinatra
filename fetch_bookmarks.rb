#!/usr/bin/ruby

require 'rubygems'
require 'rfeedparser'
require 'pacc/tokyotyrant'

url = 'http://feeds.delicious.com/v2/rss/paul.annesley?count=8'
cache = Pacc::TokyoTyrantCache.new('http://localhost:1978/pacc/')
bookmarks = cache.set 'bookmarks', FeedParser.parse(url)['entries']

puts "Fetched #{bookmarks.length} entries from delicious.com:"
bookmarks.each do |entry|
  puts " * #{entry['title']}"
end
