require 'open-uri'
require 'rexml/document'
require 'net/http'
require 'aws/s3'
require 'taglib'
require 'RMagick'

include AWS::S3
AWS::S3::Base.establish_connection!(
  :access_key_id     => 'AKIAJIIBLPNSSKSEWS5A',
  :secret_access_key => '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'
)

require 'parse-ruby-client'
Parse.init :application_id => "8fbBNwG2gvwFskbc3SjlO34qmidJkF3pCVPTuVc0",
					 :master_key => "HhJryin0t8OMP2mOBC3UkJKqyIDFxXMfVGFLtxCq"

query  = Parse::Query.new("Media")
query.limit = 1000
currentEpisodes = query.get

titles = {}
currentEpisodes.each do |episode| 
	titles[episode["title"]] = true;
end

xml = open("http://feeds.feedburner.com/uhhyeahdude/podcast").read
document = REXML::Document.new xml

# Get list of images in bucket
bucket = Bucket.find('uhhyeahdude')
objects = bucket.objects
keys = []
bucket.objects.each do |object|
	keys << object.key
end

episodes = []
done = false
document.elements.each("rss/channel/item") do |item|
	episode = Parse::Object.new("Media")

	episode[:title] = item.elements["title"].text
	episode[:desc] = item.elements["description"].text.gsub(/<[img|br].*>/, "")
	episode[:date] = DateTime.parse(item.elements["pubDate"].text).to_time.to_i
	episode[:url] = item.elements["enclosure"].attributes["url"]
	episode[:duration] = item.elements["itunes:duration"].text
	episode[:mediaType] = "Episode"

	imageFileName = episode[:url].split("/").last.sub("mp3", "jpg").sub("mov", "jpg").gsub("%20", "+")
	episode[:imageUrl] = "https://s3.amazonaws.com/uhhyeahdude/" + imageFileName
	episode[:thumbUrl] = "https://s3.amazonaws.com/uhhyeahdude/thumbs/" + imageFileName

	imageKey = imageFileName
	thumbKey = "thumbs/" + imageFileName

	foundImage = false
	foundThumb = false
	keys.each do |key|
		if key == imageKey then
			foundImage = true
		end
		if key == thumbKey then
			foundThumb = true
		end
	end

	if !foundImage || !foundThumb then
		puts "did not find " + imageKey
		open("some.mp3", "wb") do |file|
		  open (episode[:url]) do |uri|
		    file.write(uri.read)
		  end
		end

		tempImage = "defaultEpisode.jpg"
		gotCover = false
		TagLib::MPEG::File.open("some.mp3") do |file|
		  tag = file.id3v2_tag

		  # Attached picture frame
		  cover = tag.frame_list('APIC').first
		  if (cover.class != NilClass) then
		  	tempImage = "cover.jpg"
		  	gotCover = true
			  f = File.open(tempImage, "w+")
			  f.write cover.picture
			  f.close
			end
		end	
		File.delete("some.mp3")

		img = Magick::ImageList.new tempImage
		thumb = img.resize_to_fill(150, 150)
		thumb.write "thumb.jpg"

		S3Object.store(imageKey, open(tempImage), 'uhhyeahdude', :access => :public_read)
		S3Object.store(thumbKey, open("thumb.jpg"), 'uhhyeahdude', :access => :public_read)
		if gotCover then
			File.delete("cover.jpg")
		end
		File.delete("thumb.jpg")
	end

	if titles[episode[:title]] == nil then
		episodes << episode
		puts "Needs " + episode[:title]
	end
end

batch = Parse::Batch.new
episodes.each do |episode|
	batch.create_object(episode)
end
batch.run!

if episodes.length > 0 then 
	S3Object.store('update', Time.now.to_i.to_s, 'uhhyeahdude', :access => :public_read)
end