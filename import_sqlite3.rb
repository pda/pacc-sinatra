#!/usr/bin/ruby

require 'rubygems'
require 'pacc/couch'
require 'sqlite3'
require 'time'

couch = Pacc::Couch.new('http://localhost:5984/pacc')

sqlite = SQLite3::Database.new('tmp/pdawebsite.sqlite3')
sqlite.results_as_hash = true

# delete existing posts from CouchDB
couch.view('blog/posts').rows.each do |row|
  puts "Deleting blogpost #{row['_id']} - #{row['title']}"
  couch.delete row['_id'], row['_rev']
end

# import blog posts
post_id_map = {}
sqlite.execute 'SELECT * FROM blog_blogpost ORDER BY timecreated' do |row|
  created = DateTime.parse(row['timecreated'])
  modified = DateTime.parse(row['timemodified'])
  id = "%04d-%02d-%s" % [ created.year, created.month, row['slug'] ]
  post_id_map[row['id']] = id
  puts "Importing blogpost #{id} - #{row['title']}"
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

# delete existing comments from CouchDB
couch.view('blog/allcomments').rows.each do |row|
  puts "Deleting comment #{row['_id']} by #{row['authorname']} from #{row['timecreated']}"
  couch.delete row['_id'], row['_rev']
end

sqlite.execute 'SELECT * FROM blog_blogpostcomment WHERE approved = 1 ORDER BY id' do |row|
  created = DateTime.parse(row['timecreated'])
  row['post_id'] = post_id_map[row['blogpost_id']]
  puts "Importing comment #%s re %s by %s on %s" % row.values_at('id','post_id','authorname','timecreated')
  document = {
    :type => 'blogpostcomment',
    :blogpost_id => row['post_id'],
    :timecreated => created.strftime('%Y/%m/%d %H:%M:%S %z'),
    :authorname => row['authorname'],
    :authoremail => row['authoremail'],
    :authorurl => row['authorurl'],
    :authorip => row['authorip'],
    :authoruseragent => row['authoruseragent'],
    :content => row['content'],
  }
  couch.post(document)
end
