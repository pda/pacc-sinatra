#!/usr/bin/ruby

# aptitude install libsqlite3-ruby

require 'rubygems'
require 'pacc/couch'
require 'sqlite3'
require 'time'

DATE_FORMAT = '%Y/%m/%d %H:%M:%S %z'

couch = Pacc::Couch.new('http://localhost:5984/pacc')

sqlite = SQLite3::Database.new('tmp/pdawebsite.sqlite3')
sqlite.results_as_hash = true

puts "Deleting existing posts from CouchDB..."
couch.view('blog/posts').rows.each do |row|
  puts "Deleting blogpost #{row['_id']} - #{row['title']}"
  couch.delete row['_id'], row['_rev']
end

puts "Importing blog posts..."
post_id_map = {}
sqlite.execute 'SELECT * FROM blog_blogpost ORDER BY timecreated' do |row|
  created = Time.parse(row['timecreated'])
  modified = Time.parse('%s GMT' % row['timecreated'])
  id = "%04d-%02d-%s" % [ created.year, created.month, row['slug'] ]
  post_id_map[row['id']] = id
  puts "Importing blogpost #{id} - #{row['title']}"
  document = {
    :type => 'blogpost',
    :slug => row['slug'],
    :uid => row['uid'],
    :title => row['title'],
    :timecreated => created.strftime(DATE_FORMAT),
    :timemodified => modified.strftime(DATE_FORMAT),
    :content => row['content'],
    :commentable => row['allowcomments'],
  }
  couch.put(id, document)
end

puts "Deleting Comments..."
# delete existing comments from CouchDB
couch.view('blog/all_comments').rows.each do |row|
  puts "Deleting comment #{row['_id']} by #{row['authorname']} from #{row['timecreated']}"
  couch.delete row['_id'], row['_rev']
end

puts "Importing comments..."
sqlite.execute 'SELECT * FROM blog_blogpostcomment WHERE approved = 1 ORDER BY id' do |row|
  created = Time.parse(row['timecreated'])
  row['post_id'] = post_id_map[row['blogpost_id']]
  puts "Importing comment #%s re %s by %s on %s" % row.values_at('id','post_id','authorname','timecreated')
  document = {
    :type => 'blogpostcomment',
    :blogpost_id => row['post_id'],
    :timecreated => created.strftime(DATE_FORMAT),
    :authorname => row['authorname'],
    :authoremail => row['authoremail'],
    :authorurl => row['authorurl'],
    :authorip => row['authorip'],
    :authoruseragent => row['authoruseragent'],
    :content => row['content'],
  }
  couch.post(document)
end
