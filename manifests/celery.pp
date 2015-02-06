define neurovault::celery (
    $redis_apt_repo,
    $env_path,
    $system_user
)

{

  package { 'software-properties-common':
    ensure => installed,
  } ->

  exec { 'add_redis_repo':
    command => "add-apt-repository $redis_apt_repo",
  } ->

  exec { "update_packages_for_redis":
    command => "apt-get update"
  } ->

  package { 'redis-server':
    ensure => installed,
  } ->

  # configure init and defaults
  file { "/etc/init.d/neurovault-tasks":
    ensure => present,
    content => template('neurovault/celery_init.sh'),
    owner => root,
    group => root,
    mode => 0755,
  } ->

  # configure init and defaults
  file { "/etc/init.d/celeryev":
    ensure => present,
    content => template('neurovault/celerycam_init.sh'),
    owner => root,
    group => root,
    mode => 0755,
  } ->

  file { "/etc/default/neurovault-tasks":
    ensure => present,
    content => template('neurovault/celery_defaults.sh'),
    owner => root,
    group => root,
    mode => 644,
  } ->

  file { "/etc/default/celeryev":
    ensure => present,
    content => template('neurovault/celerycam_defaults.sh'),
    owner => root,
    group => root,
    mode => 644,
  } ->

  file_line { "fix_default_1":
    path  => "/etc/default/neurovault-tasks",
    line  => "CELERYD_VIRTUALENV=\"$env_path\"",
    match => "^CELERYD_VIRTUALENV",
  } ->

  file_line { "fix_default_2":
    path  => "/etc/default/neurovault-tasks",
    line  => "CELERYD_USER=\"$system_user\"",
    match => "^CELERYD_USER",
  } ->

  file_line { "fix_default_3":
    path  => "/etc/default/neurovault-tasks",
    line  => "CELERYD_GROUP=\"$system_user\"",
    match => "^CELERYD_GROUP",
  } ->

  #config init scripts for boot
  exec { "config_boot1":
    command => "update-rc.d neurovault-tasks defaults",
    onlyif => "test -e /etc/init.d/neurovault-tasks",
  } ->

  exec { "config_boot2":
    command => "update-rc.d celeryev defaults",
    onlyif => "test -e /etc/init.d/celeryev",
  } ->

  #start the daemons
  exec { "start_task_daemon":
    command => "/etc/init.d/neurovault-tasks restart",
    onlyif => "test -e /etc/init.d/neurovault-tasks",
  } ->

  exec { "start_cam_daemon":
    command => "/etc/init.d/celeryev restart",
    onlyif => "test -e /etc/init.d/celeryev",
  }

}


