define neurovault::nginx (
  $env_path,
  $app_url,
  $app_path,
  $host_name,
  $system_user,
  $tmp_dir,
  $http_server
)

{

 # config nginx / gunicorn

  $wsgi_port = "8088"

  package { "gunicorn":
      ensure => "removed"
      #ensure => "installed"
  } ->

  # python::gunicorn { $host_name:
  #   ensure      => present,
  #   virtualenv  => $env_path,
  #   mode        => 'django',
  #   owner        => $system_user,
  #   group       => $system_user,
  #   dir         => $app_path,
  #   bind        => '127.0.0.1:8088',
  # }

  class { "uwsgi": }

  uwsgi::resource::app { "django":
    options => {
      "socket"    => "127.0.0.1:$wsgi_port",
      "master"    => "true",
      "plugin"    => "python",
      "vhost"     => "true",
      "processes" => "4",
      "pythonpath"=> "/opt/nv-env",
      "wsgi-file" => "$app_path/neurovault/wsgi.py",
      "virtualenv"=> $env_path,
      "logto"     => "/var/log/$host_name-uwsgi.log",
    }
  }

  class { 'nginx': }

  nginx::resource::vhost { $host_name:
    ensure                => present,
    listen_port           => 80,
    www_root              => '/var/www',
    use_default_location => false
  }

  nginx::resource::upstream { 'neurovault-uwsgi':
    ensure  => present,
    members => [
      '127.0.0.1:$wsgi_port'
    ],
  }

  nginx::resource::location { 'root':
    ensure          => present,
    vhost           => $host_name,
    location        => '/',
    proxy           => 'http://neurovault-uwsgi',
  }

  nginx::resource::location { 'static':
    ensure          => present,
    vhost           => $host_name,
    location        => '/static',
    location_alias           => "$app_path/neurovault/static",
  }

  nginx::resource::location { 'pub-media':
    ensure          => present,
    vhost           => $host_name,
    location        => '/pub/media',
    location_alias           => "$app_path/neurovault/pub-media",
  }

  nginx::resource::location { 'secure-media':
    ensure          => present,
    vhost           => $host_name,
    internal        => true,
    location        => '/private/media/images',
    location_alias  => "$app_path/image_data/images",
  }


}
