require 'open-uri'
require 'rexml/document'
require 'net/http'
require 'aws/s3'
require 'taglib'
require 'RMagick'

# these credentials have been revoked

include AWS::S3
AWS::S3::Base.establish_connection!(
  :access_key_id     => 'AKIAJIIBLPNSSKSEWS5A',
  :secret_access_key => '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'
)

require 'parse-ruby-client'
Parse.init :application_id => "8fbBNwG2gvwFskbc3SjlO34qmidJkF3pCVPTuVc0",
					 :master_key => "HhJryin0t8OMP2mOBC3UkJKqyIDFxXMfVGFLtxCq"

puts 'getting existing Parse objects'
query  = Parse::Query.new("Media")
query.limit = 1000
@currentEpisodes = query.get

titles = {}
@currentEpisodes.each do |episode| 
	titles[episode["title"]] = true;
end

def currentEpisode(title)
	@currentEpisodes.each do |episode|
		if episode["title"] == title then
			return episode
		end
	end
	return nil
end

puts 'getting latest from RSS feed'
xml = open("http://feeds.feedburner.com/uhhyeahdude/podcast").read
document = REXML::Document.new xml

puts 'getting S3 listings'
# Get list of images in bucket
bucket = Bucket.find('uhhyeahdude')
objects = bucket.objects
keys = []
bucket.objects.each do |object|
	keys << object.key
end

begin
	puts 'scraping show notes'
	load 'scrape.rb'
rescue => ex
	puts 'scraping failed'
	@episode_notes = {}
end
newEpisodes = []
updatedEpisodes = []
done = false
document.elements.each("rss/channel/item") do |item|

	title = item.elements["title"].text
	desc = item.elements["description"].text.gsub(/<[img|br].*>/, "")
	date = DateTime.parse(item.elements["pubDate"].text).to_time.to_i
	url = item.elements["enclosure"].attributes["url"]
	duration = item.elements["itunes:duration"].text
	mediaType = "Episode"
	imageFileName = url.split("/").last.sub("mp3", "jpg").sub("mov", "jpg").gsub("%20", "+")
	imageUrl = "https://s3.amazonaws.com/uhhyeahdude/" + imageFileName
	thumbUrl = "https://s3.amazonaws.com/uhhyeahdude/thumbs/" + imageFileName
	notes = ""
	links = []

	note_key = title.split(" ").slice(0,2).join(" ")
	episode_note = @episode_notes[note_key]
	if episode_note then
		notes = episode_note[:notes]
		links = episode_note[:links]
	end

	episode = currentEpisode(title)
	if episode == nil then
		episode = Parse::Object.new("Media")
		episode[:title] = title
		episode[:desc] = desc
		episode[:date] = date
		episode[:url] = url
		episode[:duration] = duration 
		episode[:mediaType] = mediaType

		episode[:imageUrl] = imageUrl
		episode[:thumbUrl] = thumbUrl

		episode[:notes] = notes
		episode[:links] = links

		puts "Adding " + episode[:title]
		newEpisodes << episode
	else
		updateEpisode = false
		if episode["desc"] != desc
			episode["desc"] = desc
			updateEpisode = true
		end
		if episode["date"] != date
			episode["date"] = date
			updateEpisode = true
		end
		if episode["url"] != url
			episode["url"] = url
			updateEpisode = true
		end
		if episode["duration"] != duration
			episode["duration"] = duration
			updateEpisode = true
		end
		if episode["mediaType"] != mediaType
			episode["mediaType"] = mediaType
			updateEpisode = true
		end
		if episode["imageUrl"] != imageUrl
			episode["imageUrl"] = imageUrl
			updateEpisode = true
		end
		if episode["thumbUrl"] != thumbUrl
			episode["thumbUrl"] = thumbUrl
			updateEpisode = true
		end
		if episode["notes"] != notes && notes != ""
			episode["notes"] = notes
			updateEpisode = true
			puts "notes"
		end
		if episode["links"] != links && links != []
			puts episode["links"]
			puts links
			
			episode["links"] = links
			updateEpisode = true

		end

		if updateEpisode then
			puts "need to update " + episode["title"]
			updatedEpisodes << episode
		end
	end

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
end

batch = Parse::Batch.new
newEpisodes.each do |episode|
	batch.create_object(episode)
end
batch.run!

updatedEpisodes.each_slice(10).each do |slice|
	batch = Parse::Batch.new
	slice.each do |episode|
		batch.update_object(episode)
	end
	batch.run!
end


if newEpisodes.length > 0 then 
	S3Object.store('update', Time.now.to_i.to_s, 'uhhyeahdude', :access => :public_read)
end
