define neurovault::vagrant (
  $host_name,
  $httpd_user,
  $socket_path
)

{
  #vagrant-only customizations (permissions)


  exec { "set_uwsgi_uid":
    command => "sed -i.bak 's|uid = www-data|uid = $httpd_user|g' /etc/uwsgi/apps-available/$host_name.ini",
    onlyif      => "test -f /vagrant/Vagrantfile",
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ]
  }

  exec { "set_uwsgi_gid":
    command => "sed -i.bak 's|gid = www-data|gid = $httpd_user|g' /etc/uwsgi/apps-available/$host_name.ini",
    onlyif      => "test -f /vagrant/Vagrantfile",
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ]
  }

  exec { "set_uwsgi_conf_uidgid":
    command => "sed -i.bak 's|--uid www-data --gid www-data|--uid $httpd_user --gid $httpd_user|g' /etc/init/uwsgi.conf",
    onlyif      => "test -f /vagrant/Vagrantfile",
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ]
  }

  exec { "nginx_runasuser":
    command => "sed -i.bak 's|user www-data;|user $httpd_user $httpd_user;|g' /etc/nginx/nginx.conf",
    onlyif      => "test -f /vagrant/Vagrantfile",
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ]
  }

  exec { 'set_uwsgi_log':
    command     => "chown -R $httpd_user.$httpd_user /var/log/uwsgi/$host_name.log",
    onlyif      => "test -f /vagrant/Vagrantfile",
    path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  }

  exec { 'set_uwsgi_pid':
    command     => "chown $httpd_user.$httpd_user /tmp/neurovault-uwsgi.pid",
    onlyif      => "test -f /vagrant/Vagrantfile",
    path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  }

  exec { 'set_uwsgi_sock':
    command     => "chown $httpd_user.$httpd_user $socket_path",
    onlyif      => ["test -f /vagrant/Vagrantfile","test -f $socket_path"],
    path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  }

}
