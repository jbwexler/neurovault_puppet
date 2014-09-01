define neurovault::main (

  $env_path,
  $db_name,
  $db_username,
  $db_userpassword,
  $app_url,
  $host_name,
  $system_user,
  $tmp_dir,
  $repo_url,
  $neurodeb_list,
  $neurodeb_sources,
  $neurodeb_apt_key,
  $http_server
)

{

  class { 'postgresql::server': }

  $app_path = "$env_path/NeuroVault"

  # Add most paths
  Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", }

  # --install neurodebian
  exec { "install_neurodeb_apt_loc":
    command => "wget -O- $neurodeb_list | sudo tee $neurodeb_list_loc"
  } ->
  exec { "install_neurodeb_apt_key":
    command => "apt-key adv --recv-keys --keyserver $neurodeb_apt_key"
  } ->
  exec { "update_packages":
    command => "apt-get update"
  } ->

  ###
  # install system prereqs
  ###

  package { "libhdf5-dev":
      ensure => "installed"
  } ->

  package { "liblapack-dev":
      ensure => "installed"
  } ->
# psycopg2 deps
  package { "libpq-dev":
      ensure => "installed"
  } ->

  package { "libblas-dev":
      ensure => "installed"
  } ->

  package { "libgeos-dev":
      ensure => "installed"
  } ->

  # lxml deps
  package { "libxml2-dev":
      ensure => "installed"
  } ->

  # lxml deps
  package { "libxslt1-dev":
      ensure => "installed"
  } ->

  package { "gfortran":
      ensure => "installed"
  } ->

  package { "libfreetype6-dev":
      ensure => "installed"
  } ->

  package { "libpng-dev":
      ensure => "installed"
  } ->

  # inexplicably, libpng-dev and libfreetype6-dev don't seem to satisfy the reqs
  #exec { "apt-matplotlib-deps":
  #  command => "apt-get -y build-dep python-matplotlib",
  #} ->

  package { "python-numpy":
      ensure => "installed"
  } ->

  package { "python-matplotlib":
      ensure => "installed"
  } ->

  package { "python-scipy":
      ensure => "installed"
  } ->

  package { "python-h5py":
      ensure => "installed"
  } ->

  package { "python-nibabel":
      ensure => "installed"
  } ->

  package { "python-lxml":
      ensure => "installed"
  } ->

  package { "python-shapely":
      ensure => "installed"
  } ->

  package { "python-html5lib":
      ensure => "installed"
  } ->

  package { "coffeescript":
      ensure => "installed"
  } ->

  file { "/opt":
    group => $system_user,
    mode => 775,
    ensure => directory
  } ->

  class { 'python':
    version => 'system',
    dev => true,
    virtualenv => true,
    pip => true,
    manage_gunicorn => false
  } ->

  python::virtualenv { $env_path:
    ensure => present,
    owner => $system_user,
    group => $system_user,
    cwd => $env_path,
    systempkgs => true, # using system packages from NeuroDebian for python deps
  } ->

  # download code from repo
  exec { "clone-nv-app":
    command => "git clone $repo_url",
    creates => "$app_path",
    user => $system_user,
    cwd => $env_path
  } ->

  python::pip { 'numpy':
    pkgname => 'numpy',
    virtualenv => $env_path,
    owner => $system_user,
    ensure => present
  } ->

  python::pip { 'cython':
    pkgname => 'cython',
    virtualenv => $env_path,
    owner => $system_user,
    ensure => present
  } ->

  # manually install pycortex (pip packaging is broken)
  exec { "clone-pycortex":
    command => "git clone https://github.com/gallantlab/pycortex.git",
    creates => "$tmp_dir/pycortex",
    user => $system_user,
    cwd => $tmp_dir
  } ->

  exec { "build-pycortex":
    command => "$env_path/bin/python setup.py install",
    user => $system_user,
    cwd => "$tmp_dir/pycortex"
  } ->

  python::requirements { "$app_path/requirements.txt":
    virtualenv => $env_path,
    owner => $system_user,
    group => $system_user,
    forceupdate => true,
  } ->

  # config database

  postgresql::server::db { $db_name:
    user => $db_username,
    password => $db_userpassword
  } ->

  neurovault::http { 'httpd config':
    env_path => $env_path,
    app_url => $app_url,
    app_path => $app_path,
    host_name => $host_name,
    system_user => $system_user,
    tmp_dir => $tmp_dir,
    http_server => $http_server
  }

  # TODO: config settings file (needs MEDIA_URL)
  # TODO: collectstatic
  # TODO: fix wsgi file with virtualenv

}
