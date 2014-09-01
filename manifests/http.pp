define neurovault::http (
  $env_path,
  $app_url,
  $app_path,
  $host_name,
  $system_user,
  $tmp_dir,
  $http_server
)

{

  if $http_server == 'nginx' {

    neurovault::nginx { 'conf_nginx':
      env_path => $env_path,
      app_url => $app_url,
      app_path => $app_path,
      host_name => $host_name,
      system_user => $system_user,
      tmp_dir => $tmp_dir,
      http_server => $http_server
    }

  } elsif $http_server == 'apache' {

    neurovault::apache { 'conf_apache':
      env_path => $env_path,
      app_url => $app_url,
      app_path => $app_path,
      host_name => $host_name,
      system_user => $system_user,
      tmp_dir => $tmp_dir,
      http_server => $http_server
    }

  }

}
