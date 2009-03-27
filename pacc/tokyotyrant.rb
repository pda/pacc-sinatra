require 'httpclient'
require 'json'

module Pacc

# Stores objects as JSON in Tokyo Tyrant
class TokyoTyrantCache

  def initialize(baseurl)
    @baseurl = baseurl
    @client = HTTPClient.new
  end

  def get(key)
    begin
      JSON.parse(@client.get_content(@baseurl + key))
    rescue HTTPClient::BadResponseError
      set key, yield
    end
  end

  def set(key, value)
    @client.put(@baseurl + key, JSON.generate(value))
    value
  end

end

end
