define neurovault::nginx (
  $env_path,
  $app_url,
  $app_path,
  $host_name,
  $system_user,
  $httpd_user,
  $tmp_dir,
  $http_server,
  $private_media_root,
  $private_media_url,
  $socket_path,
  $pycortex_datastore
)

{

 # config nginx / uwsgi

  class { "uwsgi": }

  uwsgi::resource::app { $host_name:
    options => {
      "socket"           => $socket_path,
      "master"           => "true",
      "vhost"            => "true",
      "processes"        => "8",
      "threads"          =>  "8",
      "post-buffering"   =>"true",
      "log-date"         => "true",
      "daemonize"        => "/var/log/uwsgi/$host_name.log",
      "pidfile"          => "/tmp/neurovault-uwsgi.pid",
      "harakiri"         => "20",
      "harakiri-verbose" => "true",
      "max-requests"     => "5000",
      "virtualenv"       => $env_path,
      "chdir"            => $app_path,
      "module"           => "neurovault.wsgi",

    }
  }

  exec { 'set_pycortex_dstore_mask':
    command     => "chown -R $httpd_user.$httpd_user $pycortex_datastore",
    onlyif      => "test -d $pycortex_datastore",
    unless      => "test -f /vagrant/Vagrantfile",
    path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  }

  class { 'nginx':  }

  nginx::resource::vhost { $host_name:
    ensure                => present,
    listen_port           => 80,
    www_root              => '/var/www',
    use_default_location => false,
    client_max_body_size => '1024M',
  }

  nginx::resource::upstream { 'neurovault-uwsgi':
    ensure  => present,
    members => [
      "unix:$socket_path",
    ],
  }

  nginx::resource::location { 'root':
  ensure                    => present,
    vhost                   => $host_name,
    location                => '/',
    location_custom_cfg  => {
      'uwsgi_pass' => 'neurovault-uwsgi',
      'include'    => 'uwsgi_params',
    }
  }

  nginx::resource::location { 'static':
    ensure          => present,
    vhost           => $host_name,
    location        => '/static',
    location_alias           => "$app_path/neurovault/static",
  }

  nginx::resource::location { 'secure-media':
    ensure          => present,
    vhost           => $host_name,
    internal        => true,
    location        => "/private$private_media_url",
    location_alias  => "$private_media_root/images",
  }

  exec { 'nginx_set_boot':
    command         => "update-rc.d nginx defaults",
    path            => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    returns         => [0,1],
  }

}
