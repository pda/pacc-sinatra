require 'httpclient'
require 'json'

##
# A basic datastore.
# Stores objects as JSON in an HTTP server like Tokyo Tyrant
class HttpDataStore

  def initialize(baseurl)
    @baseurl = baseurl
    @client = HTTPClient.new
  end

  def set(key, value)
    @client.put(@baseurl + key, JSON.generate(value))
  end

  def get(key)
    JSON.parse(@client.get_content(@baseurl + key))
  end

end
