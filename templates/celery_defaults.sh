CELERYD_NODES="celery"

CELERYD_VIRTUALENV="/opt/nv_env"

# Where to chdir at start.
CELERYD_CHDIR="$CELERYD_VIRTUALENV/NeuroVault"

# Python interpreter from environment.
ENV_PYTHON="$CELERYD_VIRTUALENV/bin/python"

# How to call "manage.py celery"
CELERY_BIN="$ENV_PYTHON $CELERYD_CHDIR/manage.py celery"

# Extra command-line arguments to the worker (see celery worker --help)
CELERYD_OPTS="--concurrency=2 -A neurovault.celery -E -B -Q celery --time-limit=57600 --purge"

CELERYD_MULTI="$ENV_PYTHON $CELERYD_CHDIR/manage.py celeryd_multi"

# Name of the celery config module.
CELERY_CONFIG_MODULE="celeryconfig"

# %n will be replaced with the nodename.
CELERYD_LOG_FILE="/var/log/neurovault-tasks/%n.log"
CELERYD_PID_FILE="/var/run/neurovault-tasks/%n.pid"

# Workers should run as an unprivileged user.
CELERYD_USER="vagrant"
CELERYD_GROUP="vagrant"

# Create the log and pid dirs
CELERY_CREATE_DIRS=1

# Name of the projects settings module.
export DJANGO_SETTINGS_MODULE="neurovault.settings"

