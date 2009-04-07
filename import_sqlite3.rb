#!/usr/bin/ruby

require 'rubygems'
require 'pacc/couch'
require 'sqlite3'
require 'time'

couch = Pacc::Couch.new('http://localhost:5984/pacc')
sqlite = SQLite3::Database.new('tmp/pdawebsite.sqlite3')

# delete existing posts from CouchDB
couch.view('blog/posts').rows.each do |row|
  puts "deleting #{row['_id']} - #{row['title']}"
  couch.delete row['_id'], row['_rev']
end

sqlite.results_as_hash = true
sqlite.execute 'SELECT * FROM blog_blogpost ORDER BY timecreated' do |row|
  created = DateTime.parse(row['timecreated'])
  modified = DateTime.parse(row['timemodified'])
  id = "%04d-%02d-%s" % [ created.year, created.month, row['slug'] ]
  puts "importing #{id} - #{row['title']}"
  document = {
    :type => 'blogpost',
    :slug => row['slug'],
    :title => row['title'],
    :timecreated => created.strftime('%Y/%m/%d %H:%M:%S %z'),
    :timemodified => modified.strftime('%Y/%m/%d %H:%M:%S %z'),
    :content => row['content'],
	:commentable => row['allowcomments'],
  }
  couch.put(id, document)
end
