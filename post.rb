require 'net/http'
require 'net/https'
require 'json'
require 'hmac-sha1'
require 'base64'
require 'CGI'

uri = URI.parse("https://api.parse.com/1/classes/Media")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

uri.query = URI.encode_www_form(:limit => 1000)
req = Net::HTTP::Get.new(uri.request_uri)
req["Content-Type"] = "application/json"
req["X-Parse-Application-Id"] = "8fbBNwG2gvwFskbc3SjlO34qmidJkF3pCVPTuVc0"
req["X-Parse-REST-API-Key"] = "qNgE46H7emOYu3wsuRLGpMSZVeNxCUfCP81hFSxz"

res = http.request(req)
currentEpisodes = JSON.parse(res.body)["results"]

titles = {}
currentEpisodes.each do |episode| 
	# titles[episode["title"]] = true;
	puts episode["title"]
end