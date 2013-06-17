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
		bundle = {'url':url, 'mp3':mp3Filename, 'jpg':jpgFilename, 'title':title.encode('ascii', 'ignore')}
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

from parse_rest.connection import register
from parse_rest.datatypes import Object

register("8fbBNwG2gvwFskbc3SjlO34qmidJkF3pCVPTuVc0", "qNgE46H7emOYu3wsuRLGpMSZVeNxCUfCP81hFSxz", master_key="HhJryin0t8OMP2mOBC3UkJKqyIDFxXMfVGFLtxCq")
class Media(Object):
	pass

medias = []
media = Media.Query.all().limit(1000)
for m in media:
	medias.append(m)

updates = []

for episode in episodes:
	episode['imageUrl'] = 'https://s3.amazonaws.com/uhhyeahdude/'+episode['jpg']
	episode['thumbUrl'] = 'https://s3.amazonaws.com/uhhyeahdude/thumbs/'+episode['jpg']	

for m in medias:
	for episode in episodes:
		if m.title == episode['title']:
			if hasattr(m, 'imageUrl') != True or hasattr(m, 'thumbUrl') != True:
				m.imageUrl = episode['imageUrl']
				m.thumbUrl = episode['thumbUrl']
				updates.append(m)
				print m.title + " needs an update"

def chunks(l, n):
    """ Yield successive n-sized chunks from l.
    """
    for i in xrange(0, len(l), n):
        yield l[i:i+n]

from parse_rest.connection import ParseBatcher
batcher = ParseBatcher()
for chunk in chunks(updates, 50):
	batcher.batch_save(chunk)






