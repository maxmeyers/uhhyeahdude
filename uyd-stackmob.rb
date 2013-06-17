require 'open-uri'
require 'rexml/document'
require 'net/http'
require 'net/https'
require 'json'
require 'hmac-sha1'
require 'base64'
require 'CGI'

uri = URI("http://api.stackmob.com/media")

req = Net::HTTP::Get.new(uri)
req["X-StackMob-API-Key"]
req["Content-Type"] = "application/json"
req["X-StackMob-API-Key"] = "393372a5-9d05-4019-9966-8a2c5e89cd23"
req["Accept"] = "application/vnd.stackmob+json; version=0"
res = Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(req)
end
currentEpisodes = JSON.parse(res.body)
titles = {}
currentEpisodes.each do |episode| 
	titles[episode["title"]] = true;
end

xml = open("http://feeds.feedburner.com/uhhyeahdude/podcast").read
document = REXML::Document.new xml

episodes = []
done = false
document.elements.each("rss/channel/item") do |item|
	episode = {}

	episode[:title] = item.elements["title"].text
	episode[:desc] = item.elements["description"].text
	episode[:date] = DateTime.parse(item.elements["pubDate"].text).to_time.to_i
	episode[:url] = item.elements["enclosure"].attributes["url"]
	episode[:duration] = item.elements["itunes:duration"].text

	if titles[episode[:title]] == nil then
		episodes << episode
	end
end

uri = URI.parse("https://api.stackmob.com/user/accessToken")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

req = Net::HTTP::Post.new(uri.request_uri)
req["Content-Type"] = "application/x-www-form-urlencoded"
req["X-StackMob-API-Key"] = "393372a5-9d05-4019-9966-8a2c5e89cd23"
req["Accept"] = "application/vnd.stackmob+json; version=0"
req["X-StackMob-User-Agent"] = "ruby"

req.body = URI.encode_www_form(:username => "max", :password => "whoops", :token_type => "mac")
res = http.request(req)
response = JSON.parse(res.body)
access_token = response["access_token"]
mac_key = response["mac_key"]

uri = URI("https://api.stackmob.com/media")

ts = Time.now.to_i.to_s
nonce = rand.to_s[2..18]
nl = "\n"
base = ts + nl + nonce + nl + "POST" + nl + "/media" + nl + "api.stackmob.com" + nl + "443" + nl + nl
hash = HMAC::SHA1.digest(mac_key, base)
mac = Base64.encode64(hash).chomp

auth_string = 'MAC id="' + access_token + '",ts="' + ts + '",nonce="' + nonce + '",mac="' + mac +'"'

req = Net::HTTP::Post.new(uri)

req["Content-Type"] = "application/json"
req["X-StackMob-API-Key"] = "393372a5-9d05-4019-9966-8a2c5e89cd23"
req["X-StackMob-User-Agent"] = "ruby"
req["Accept"] = "application/vnd.stackmob+json; version=0"
req["Authorization"] = auth_string

puts episodes.length
req.body = episodes.to_json

res = http.request(req)

puts res.body