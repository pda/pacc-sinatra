require 'httpclient'
require 'json'

module Pacc

# A simple CouchDB interface
class Couch
  def initialize(baseurl)
    @baseurl = baseurl
    @client = HTTPClient.new
  end
  def view(path)
    CouchView.new(JSON.parse(@client.get_content("#{@baseurl}/_view/#{path}")))
  end
end

# a CouchDB view
class CouchView
  attr_reader :rows
  def initialize(data)
    @data = data
    @rows = data['rows'].map{ |row| row['value'] }
  end
end

end
