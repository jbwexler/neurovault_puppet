define neurovault::nginx (
  $env_path,
  $app_url,
  $app_path,
  $host_name,
  $system_user,
  $tmp_dir,
  $http_server,
)

{

 # config apache / wsgi

  class { 'apache':
    purge_configs => false,
    default_mods => true,
    default_vhost => false,
    mpm_module => 'worker',
  }

  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::proxy_html
  include apache::mod::wsgi

  apache::vhost { $host_name:
    port => '80',
    docroot => '/var/www',
    serveraliases => ["www.$host_name"],

    wsgi_application_group => '%{GLOBAL}',
    wsgi_daemon_process => 'neurovault',
    wsgi_daemon_process_options => {
      processes => '2',
      threads => '15',
      display-name => '%{GROUP}',
      python-path => "$env_path/lib/python2.7/site-packages",
    },
    wsgi_process_group => 'neurovault',
    wsgi_script_aliases => {
      "/" => "$app_path/neurovault/wsgi.py" ,
    },

    aliases => [
      { alias => "/media",
        path => "$app_path/neurovault/media",
      },
      { alias => "/static",
        path => "$app_path/neurovault/static",
      }
    ],

    custom_fragment => "
      <Directory \"$app_path/neurovault\">
        AuthType Basic
        AuthName \"Dev\"
        AuthBasicProvider wsgi
        Require valid-user
        WSGIAuthUserScript /home/grivera/nv-auth.wsgi
      </Directory>
    ",
  }

}
