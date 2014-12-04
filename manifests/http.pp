define neurovault::http (
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
  $pycortex_datastore,
)

{

  if $http_server == 'nginx' {

    $socket_path = "/tmp/neurovault.sock"

    neurovault::nginx { 'conf_nginx':
      env_path => $env_path,
      app_url => $app_url,
      app_path => $app_path,
      host_name => $host_name,
      system_user => $system_user,
      httpd_user => $httpd_user,
      tmp_dir => $tmp_dir,
      http_server => $http_server,
      private_media_root => $private_media_root,
      private_media_url => $private_media_url,
      socket_path => $socket_path,
      pycortex_datastore => $pycortex_datastore,
    } ->

    neurovault::vagrant { 'conf_vagrant_perms':
      host_name => $host_name,
      httpd_user => $httpd_user,
      socket_path => $socket_path,
    }

  } elsif $http_server == 'apache' {

    neurovault::apache { 'conf_apache':
      env_path => $env_path,
      app_url => $app_url,
      app_path => $app_path,
      host_name => $host_name,
      system_user => $system_user,
      httpd_user => $httpd_user,
      tmp_dir => $tmp_dir,
      http_server => $http_server,
      pycortex_datastore => $pycortex_datastore,
    }

  }

}
