# Event cam config
CELERYEV_PID_FILE="/var/run/neurovault-tasks/celerycam.pid"
CELERYEV_LOG_FILE="/var/log/neurovault-tasks/celerycam.log"

CELERYEV="$ENV_PYTHON $CELERYD_CHDIR/manage.py celerycam"

CELERYEV_USER=$CELERYD_USER

CELERYEV_GROUP=$CELERYD_GROUP

CELERYEV_CAM="djcelery.snapshot.Camera"
