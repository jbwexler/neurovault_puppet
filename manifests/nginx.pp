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

   package { "gunicorn":
      ensure => "installed"
  } ->

  python::gunicorn { $host_name:
    ensure      => present,
    virtualenv  => $env_path,
    mode        => 'django',
    owner        => $system_user,
    group       => $system_user,
    dir         => $app_path,
    bind        => '127.0.0.1:8000',
  }

  class { 'nginx': }

  nginx::resource::vhost { $host_name:
    ensure                => present,
    listen_port           => 80,
    www_root              => '/var/www',
    use_default_location => false
  }

  nginx::resource::upstream { 'gunicorn':
    ensure  => present,
    members => [
      '127.0.0.1:8000'
    ],
  }

  nginx::resource::location { 'root':
    ensure          => present,
    vhost           => $host_name,
    location        => '/',
    proxy           => 'http://gunicorn',
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
