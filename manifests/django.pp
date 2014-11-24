define neurovault::django (
    $env_path,
    $app_path,
    $app_url,
    $host_name,
    $system_user,
    $httpd_user,
    $http_server,
    $db_name,
    $db_username,
    $db_userpassword,
    $dbbackup_storage,
    $dbbackup_tokenpath,
    $dbbackup_appkey,
    $dbbackup_secret,
    $start_debug,
    $private_media_root,
    $private_media_url,
    $private_media_existing,
)

{
# config django settings files, database, etc

  # create secrets file
  file { "$app_path/neurovault/secrets.py":
    ensure => present,
    content => template('neurovault/secrets.py.erb'),
    owner =>  $system_user,
    group => $httpd_user,
    mode => '660'
  } ->

  # config paths for media
  file_line { "private_media_root":
    path  => "$app_path/neurovault/settings.py",
    line  => "PRIVATE_MEDIA_ROOT = '$private_media_root'",
    match => "^PRIVATE_MEDIA_ROOT.*$",
  } ->

  file_line { "private_media_url":
    path  => "$app_path/neurovault/settings.py",
    line  => "PRIVATE_MEDIA_URL = '$private_media_url'",
    match => "^PRIVATE_MEDIA_URL.*$",
  } ->

  # config db settings

  file_line { "db_db_user":
    path  => "$app_path/neurovault/settings.py",
    line  => "        'USER': '$db_username',",
    match => "^\s*'USER':\s*'[a-zA-z]*',.*$",
  } ->

  file_line { "db_db_name":
    path  => "$app_path/neurovault/settings.py",
    line  => "        'NAME': '$db_name',",
    match => "^\s*'NAME':\s*'[a-zA-z]*',.*$",
  } ->

  file_line { "db_db_password":
    path  => "$app_path/neurovault/settings.py",
    line  => "        'PASSWORD': '$db_userpassword',",
    match => "^\s*'PASSWORD':\s*'[a-zA-z]*',.*$",
  } ->

  # collect static

  exec { 'collect_staticfiles':
    command         => "$env_path/bin/python $app_path/manage.py collectstatic --noinput",
    user            => $system_user,
    cwd             => $app_path,
    onlyif          => "test ! -d $app_path/neurovault/static",
    path            => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  } ->

  # move existing archives of media, fix permissions

  exec { 'move_private_media':
    command     => "mv $private_media_existing $private_media_root",
    onlyif      => ["test -d $private_media_existing","test ! -d $private_media_root"],
    path            => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  } ->

  exec { 'chown_private_media':
    command     => "chown -R $httpd_user.$httpd_user $private_media_root",
    onlyif      => "test -d $private_media_root",
    unless      => "test -f /vagrant/Vagrantfile",
    path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  } ->

  # create media dirs (when no existing data was moved)

  file { $private_media_root:
    ensure      => "directory",
    owner       => $httpd_user,
    group       => $httpd_user,
    mode        => "700",
  }

  if $start_debug == 'true' {
      file_line { "set_django_debug":
        path  => "$app_path/neurovault/settings.py",
        line  => "DEBUG = True",
        match => "^DEBUG =.*$",
      }
  }

}
