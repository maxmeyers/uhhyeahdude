from parse_rest.connection import register
from parse_rest.datatypes import Object
import re

register("8fbBNwG2gvwFskbc3SjlO34qmidJkF3pCVPTuVc0", "qNgE46H7emOYu3wsuRLGpMSZVeNxCUfCP81hFSxz", master_key="HhJryin0t8OMP2mOBC3UkJKqyIDFxXMfVGFLtxCq")
class Media(Object):
	pass

medias = []
media = Media.Query.all().limit(1000)
for m in media:
	if hasattr(m, "desc"):
		m.desc = re.sub("<[br|img].*>", "", m.desc)
		print m.desc
		medias.append(m)

def chunks(l, n):
    """ Yield successive n-sized chunks from l.
    """
    for i in xrange(0, len(l), n):
        yield l[i:i+n]

from parse_rest.connection import ParseBatcher
batcher = ParseBatcher()
for chunk in chunks(medias, 50):
	batcher.batch_save(chunk)
