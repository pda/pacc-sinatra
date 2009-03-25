#!/usr/bin/ruby

require 'rubygems'
require 'rfeedparser'
require 'datastore'

feed = FeedParser.parse('http://feeds.delicious.com/v2/rss/paul.annesley?count=8')
cache = HttpDataStore.new('http://localhost:1978/pacc/')
cache.set('bookmarks', feed['entries'])
