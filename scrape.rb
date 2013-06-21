require 'open-uri'
require 'nokogiri'
include Nokogiri

index = 0
finished = false
@last = -1

@episode_notes = {}

def lastPage(doc)
	div = doc.css('div.paginate').first
	div.css('a').last.attribute('href').to_s.split('/').last.sub("P", "").to_i
end

while !finished
	raw = open("http://uhhyeahdude.com/index.php/show_notes/P#{index}").read.gsub("<!-- <p", "<p").gsub("p> -->", "p>")
	doc = HTML.parse(raw)
	if @last == -1 then
		@last = lastPage(doc)
	end

	doc.css('.entry').each do |entry|
		episode = {}
		episode[:title] = entry.css('h2').first.css('a').first.inner_html.split(" — ").first.chomp
		episode[:notes] = entry.css('p').first.inner_html.gsub("<br>", "")
		links = []
		links_p = entry.css('p')[1]
		if links_p then
			links_p.css('a').each do |a|
				link = {}
				link["url"] = a.attribute('href').to_s
				link["title"] = a.inner_html
				links << link
			end
		end
		# puts episode[:title]
		# puts links
		# puts 
		# puts
		episode[:links] = links
		@episode_notes[episode[:title]] = episode
	end	

	if (index == @last)
		finished = true
	end
	index = [index+15, @last].min
end