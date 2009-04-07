require 'httpclient'
require 'json'

module Pacc

# A simple CouchDB interface
class Couch

  def initialize(baseurl)
    @baseurl = baseurl
    @client = HTTPClient.new
  end

  def view(path, params = {})
    CouchView.new(decode(@client.get_content(url("_view/#{path}", params))))
  end

  def get(id)
    decode(@client.get_content(url(id)))
  end

  def put(id, data)
    url = url(id)
    r = @client.put(url, encode(data))
    # TODO: better handling - actually, rewrite this whole class
	unless r.status_code == 201
      puts r.inspect
      raise "HTTP error #{r.status_code} #{r.header.reason_phrase} from PUT #{url}" unless r.status_code == 200
	end
  end

  def delete(id, revision)
    @client.delete(url(id, :rev => revision))
  end

  private

  def url(fragment, params = {})
    url = "#{@baseurl}/#{fragment}"
    # TODO: get rid of this dodginess
    url += '?' + params.map{ |k,v| "%s=%s" % [k,v] }.join('&') unless params.empty?
    url
  end

  def encode(data)
    JSON.generate(data)
  end

  def decode(json)
    JSON.parse(json)
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
