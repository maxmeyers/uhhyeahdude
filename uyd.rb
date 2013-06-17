require 'open-uri'
require 'rexml/document'
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
req["X-Parse-Master-Key"] = "HhJryin0t8OMP2mOBC3UkJKqyIDFxXMfVGFLtxCq"

res = http.request(req)
currentEpisodes = JSON.parse(res.body)["results"]

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
	episode[:desc] = item.elements["description"].text.gsub(/<[img|br].*>/, "")
	episode[:date] = DateTime.parse(item.elements["pubDate"].text).to_time.to_i
	episode[:url] = item.elements["enclosure"].attributes["url"]
	episode[:duration] = item.elements["itunes:duration"].text
	episode[:mediaType] = "Episode"

	if titles[episode[:title]] == nil then
		episodes << episode
	end
end

requests = []

episodes.each do |episode|
	request = { :method => "POST", :path => "/1/classes/Media", :body => episode}
	requests << request
end

requests.each_slice(10).to_a.each do |mini_batch|
	uri = URI.parse("https://api.parse.com/1/batch")
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE

	req = Net::HTTP::Post.new(uri.request_uri)
	req["Content-Type"] = "application/json"
	req["X-Parse-Application-Id"] = "8fbBNwG2gvwFskbc3SjlO34qmidJkF3pCVPTuVc0"
	req["X-Parse-Master-Key"] = "HhJryin0t8OMP2mOBC3UkJKqyIDFxXMfVGFLtxCq"

	req.body = {:requests => mini_batch}.to_json
	res = http.request(req)
	response = JSON.parse(res.body)

	puts response
end
