define neurovault::main (

  $env_path,
  $db_name,
  $db_username,
  $db_userpassword,
  $db_existing_sql,
  $app_url,
  $host_name,
  $system_user,
  $httpd_user,
  $tmp_dir,
  $repo_url,
  $repo_branch,
  $neurodeb_list,
  $neurodeb_sources,
  $neurodeb_apt_key,
  $http_server,
  $dbbackup_storage,
  $dbbackup_tokenpath,
  $dbbackup_appkey,
  $dbbackup_secret,
  $start_debug,
  $private_media_root,
  $private_media_url,
  $private_media_existing,
  $gmail_login_str,
  $skip_freesurfer,
  $freesurfer_dl_path,
  $freesurfer_src,
  $freesurfer_installdir,
  $freesurfer_lic_email,
  $freesurfer_lic_id,
  $freesurfer_lic_key,
  $bash_config_loc,
  $pycortex_repo,
  $pycortex_branch,
  $pycortex_datastore,
  $neurovault_data_repo,
  $provtoolbox_config_loc,
  $provtoolbox_url,
  $provtoolbox_filepath,
  $provtoolbox_zipname,
  $prov_repo_url,
  $nidmresults_repo_url,
  $nidmfsl_repo_url,
  $nidmfsl_branch,
)

{

  class { 'postgresql::server': }

  $app_path = "$env_path/NeuroVault"

  # Add most paths
  Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", }

  # --install neurodebian
  exec { "install_neurodeb_apt_loc":
    command => "wget -O- $neurodeb_list | sudo tee $neurodeb_sources"
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

  package { "git":
      ensure => "installed",
  } ->

  package { "subversion":
      ensure => "installed",
  } ->

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
    command => "git clone -b $repo_branch $repo_url",
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

  # Temp: comment pycortex from requirements, we build it manually,
  # since the pypi packaging/dependency resolution is broken (like numpy,scipy, etc)
  file { "$tmp_dir/temp_requirements.txt":
    owner => $system_user,
    group => $system_user,
    mode => 644,
    ensure => present,
    source => "$app_path/requirements.txt",
  } ->

  # Django 1.7 is pretty much required now (migrations, cli scripts)
  file_line { "change_djangoversion_reqs":
    path  => "$tmp_dir/temp_requirements.txt",
    line  => "Django==1.7.1",
    match => "^Django<?>?={0,2}.*$",
  } ->

  file_line { "comment_pycortex_from_reqs":
    path  => "$tmp_dir/temp_requirements.txt",
    line  => "#pycortex",
    match => "^#?pycortex$",
  } ->

  python::requirements { "$tmp_dir/temp_requirements.txt":
    virtualenv => $env_path,
    owner => $system_user,
    group => $system_user,
    forceupdate => true,
  } ->

  # Set up HTTP and WSGI

  neurovault::http { 'httpd config':
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
    pycortex_datastore => $pycortex_datastore,
  } ->

  # config database

  postgresql::server::db { $db_name:
    user => $db_username,
    password => $db_userpassword
  } ->

  neurovault::database { 'setup_db':
    env_path => $env_path,
    app_path => $app_path,
    system_user => $system_user,
    db_name => $db_name,
    db_username => $db_username,
    db_userpassword => $db_userpassword,
    db_existing_sql => $db_existing_sql,
  } ->

  # config outgoing mailer

  neurovault::smtpd { 'setup_postfix':
    host_name => $host_name,
    gmail_login_str => $gmail_login_str,
  } ->

  # create local settings file
  file { "$app_path/neurovault/local_settings.py":
    owner => $system_user,
    group => $system_user,
    mode => 644,
    ensure => present,
    content => template('neurovault/local_settings.py'),
  } ->

  # install Freesurfer

  neurovault::freesurfer { 'install_freesurfer':
    tmp_dir => $tmp_dir,
    skip_freesurfer => $skip_freesurfer,
    freesurfer_dl_path => $freesurfer_dl_path,
    freesurfer_src => $freesurfer_src,
    freesurfer_installdir => $freesurfer_installdir,
    freesurfer_lic_email => $freesurfer_lic_email,
    freesurfer_lic_id => $freesurfer_lic_id,
    freesurfer_lic_key => $freesurfer_lic_key,
    bash_config_loc => $bash_config_loc,
    system_user => $system_user,
    app_path => $app_path,
    neurovault_data_repo => $neurovault_data_repo,
  } ->

  # install Pycortex
  neurovault::pycortex { 'install_pycortex':
    tmp_dir => $tmp_dir,
    env_path => $env_path,
    system_user => $system_user,
    httpd_user => $httpd_user,
    app_path => $app_path,
    pycortex_repo => $pycortex_repo,
    pycortex_branch => $pycortex_branch,
    pycortex_datastore => $pycortex_datastore,
    neurovault_data_repo => $neurovault_data_repo,
  } ->

  # install FEAT support reqs
  neurovault::feat { 'install_feat_reqs':
    env_path => $env_path,
    system_user => $system_user,
    provtoolbox_config_loc => $provtoolbox_config_loc,
    provtoolbox_url => $provtoolbox_url,
    provtoolbox_filepath => $provtoolbox_filepath,
    provtoolbox_zipname => $provtoolbox_zipname,
    prov_repo_url => $prov_repo_url,
    nidmresults_repo_url => $nidmresults_repo_url,
    nidmfsl_repo_url => $nidmfsl_repo_url,
    nidmfsl_branch => $nidmfsl_branch,
  } ->

  # last, config Django

  neurovault::django  { 'django_appsetup':
    env_path => $env_path,
    app_path => $app_path,
    app_url => $app_url,
    host_name => $host_name,
    system_user => $system_user,
    httpd_user => $httpd_user,
    http_server => $http_server,
    db_name => $db_name,
    db_username => $db_username,
    db_userpassword => $db_userpassword,
    dbbackup_storage => $dbbackup_storage,
    dbbackup_tokenpath => $dbbackup_tokenpath,
    dbbackup_appkey => $dbbackup_appkey,
    dbbackup_secret => $dbbackup_secret,
    start_debug     => $start_debug,
    private_media_root => $private_media_root,
    private_media_url => $private_media_url,
    private_media_existing => $private_media_existing,
  } ->

  # restart daemons

  exec { "restart_uwsgi":
    command => "service uwsgi restart"
  } ->

  exec { "restart_nginx":
    command => "service nginx restart"
  }

}
