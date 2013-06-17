import urllib2, subprocess, os, eyeD3
from xml.dom.minidom import parse, parseString
from boto.s3.connection import S3Connection
from boto.s3.key import Key
from wand.image import Image
from wand.display import display

podcastRequest = urllib2.Request('http://feeds.feedburner.com/uhhyeahdude/podcast')
podcastListings = parseString(urllib2.urlopen(podcastRequest).read())

root = podcastListings.documentElement
channel = root.getElementsByTagName('channel')[0]

conn = S3Connection()
bucket = conn.get_bucket('uhhyeahdude')

thumbs = []
for key in bucket.list('thumbs/'):
	thumbs.append(key.name.replace('thumbs/', '').encode('ascii', 'ignore'))

downloads = []
episodes = []
for node in channel.childNodes:
	if node.nodeName == 'item':
		episode = node
		title = episode.getElementsByTagName('title')[0].childNodes[0].nodeValue
		url = episode.getElementsByTagName('enclosure')[0].getAttribute('url')
		urlComponents = url.split('/')
		mp3Filename = urlComponents[len(urlComponents)-1]
		jpgFilename = mp3Filename.replace('mp3', 'jpg').replace('mov', 'jpg').replace('%20', '+')
		foundJpg = False
		for key in thumbs:
			if key == jpgFilename:
				foundJpg = True
		bundle = {'url':url, 'mp3':mp3Filename, 'jpg':jpgFilename}
		if foundJpg == False:
			downloads.append(bundle)
		episodes.append(bundle)


if len(downloads) > 0:
	if not os.path.exists('mp3s'):
		os.mkdir('mp3s')
	if not os.path.exists('images/thumbs'):
		os.makedirs('images/thumbs')

	def downloadFile(file_name,url):
		from urllib2 import Request, urlopen, URLError, HTTPError
		
		req = Request(url)
		
		# Open the url
		try:
			f = urlopen(req)
			print "Downloading " + url
			
			# Open our local file for writing
			local_file = open(file_name, 'wb')
			#Write to our local file
			local_file.write(f.read())
			local_file.close()
			
		#handle errors
		except HTTPError, e:
			print "HTTP Error:",e.code , url
		except URLError, e:
			print "URL Error:",e.reason , url

	for download in downloads:
		mp3Path = 'mp3s/'+download['mp3']
		if not os.path.exists(mp3Path):
			downloadFile(mp3Path, download['url'])
		else:
			print 'already downloaded ' + download['mp3']
		if os.path.exists(mp3Path):
			img = False
			if not mp3Path.find('.mp3') == -1:
				tag = eyeD3.Tag()
				tag.link(mp3Path)
				if len(tag.getImages()) > 0:
					img = tag.getImages()[0]
					img.writeFile('images', download['jpg'])
			if not img:
				img = Image(filename='defaultEpisode.jpg')
				img.save(filename='images/'+download['jpg'])

			# Resize
			image = Image(filename='images/' + download['jpg'])
			width = float(image.size[0])
			height = float(image.size[1])

			image.resize(150, int((height/width)*150))
			image.save(filename='images/thumbs/'+download['jpg'])

			print 'uploading ' + download['jpg'] + ' to S3'
			key = Key(bucket)
			key.key = download['jpg']
			key.set_contents_from_filename('images/'+download['jpg'])
			key.make_public()

			thumbKey = Key(bucket)
			thumbKey.key = 'thumbs/'+download['jpg']
			thumbKey.set_contents_from_filename('images/thumbs/'+download['jpg'])
			thumbKey.make_public()

			os.remove(mp3Path)
	os.removedirs('mp3s')
else:
	print 'no downloads this time!'

print 'updating images.json'

import json
imageMap = {'images':{}, 'thumbs':{}}
try:
	imageMapRaw = urllib2.urlopen(urllib2.Request('http://meyers.co/images.json')).read()
	imageMap = json.loads(imageMapRaw)
except:
	print 'images.json either didn\'t exist or was fucked'

# add seth's corner in there
# TODO: get the number of seth's corner from media.json
for x in range(1, 16):
	num = str(x)
	if x < 10:
		num = '0'+num
	episodes.append({'mp3':'SETH'+num+'.mp4', 'jpg':'SETH'+num+'.jpg'})


updateNeeded = False
for episode in episodes:
	episode['imageUrl'] = 'https://s3.amazonaws.com/uhhyeahdude/'+episode['jpg']
	episode['thumbUrl'] = 'https://s3.amazonaws.com/uhhyeahdude/thumbs/'+episode['jpg']	

	foundInImages = False
	foundInThumbs = False

	for key in imageMap['images']:
		if key == episode['mp3']:
			if imageMap['images'][key] == episode['imageUrl']:
				foundInImages = True
			else:
				del imageMap['images'][key]

	if not foundInImages:
		updateNeeded = True
		print 'did not find ' + episode['mp3'] + ' in images'
		imageMap['images'][episode['mp3']] = episode['imageUrl']

	for key in imageMap['thumbs']:
		if key == episode['mp3']:
			if imageMap['thumbs'][key] == episode['thumbUrl']:
				foundInThumbs = True
			else:
				del imageMap['thumbs'][key]

	if not foundInThumbs:
		updateNeeded = True
		print 'did not find ' + episode['mp3'] + ' in thumbs'
		imageMap['thumbs'][episode['mp3']] = episode['thumbUrl']

if updateNeeded:
	print 'update needed'
	f = open('images.json', 'w+')
	f.write(json.dumps(imageMap))

	import ftplib
	f = open('images.json')
	remote = ftplib.FTP('meyers.co', 'meyersc1', 'N34!9jf6(a81(b5K705FKm\'g')
	remote.cwd('public_html')
	remote.storlines('STOR images.json', f)

	# key = Key(bucket)
	# key.key ='images.json'
	# key.set_contents_from_string(json.dumps(imageMap))
	# key.make_public()
else:
	print 'no update needed'