import os
import sys
from tempfile import mkdtemp

# add additional local settings here to override settings.py defaults

#ADMINS = (
#    ('You', 'you@yourdomain.com'),
#)

DEBUG = True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'neurovault',
        'USER': 'neurovault',
        'PASSWORD': 'neurovault',
        'HOST': '127.0.0.1',
    }
}

if "test" in sys.argv: 
    PRIVATE_MEDIA_ROOT=mkdtemp()
else:
    PRIVATE_MEDIA_ROOT = '/opt/image_data'ia')
PRIVATE_MEDIA_URL = '/media/images'

PYCORTEX_DATASTORE = os.path.join(BASE_DIR,'pycortex_data')

# Pycortex static data is deployed by collectstatic at build time.
STATICFILES_DIRS = (
    ('pycortex-resources', '/path/to/pycortex/cortex/webgl/resources'),
    ('pycortex-ctmcache', os.path.join(PYCORTEX_DATASTORE,'db/fsaverage/cache')),
)

os.environ["FREESURFER_HOME"] = "/opt/freesurfer"
