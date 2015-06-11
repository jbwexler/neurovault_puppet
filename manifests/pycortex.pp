define neurovault::pycortex (
  $tmp_dir,
  $env_path,
  $system_user,
  $httpd_user,
  $app_path,
  $pycortex_repo,
  $pycortex_branch,
  $pycortex_datastore,
  $neurovault_data_repo,
)

{

  $pycortex_install_root = "$env_path/lib"
  $pycortex_path = "$env_path/lib/pycortex"

  $data_dirs = [
    $pycortex_datastore,
    "$pycortex_datastore/colormaps",
    "$pycortex_datastore/temp",
    "$pycortex_datastore/db/fsaverage/transforms",
  ]

  # manually install pycortex (pip packaging is broken)
  exec { "clone-pycortex":
    command => "git clone -b $pycortex_branch $pycortex_repo",
    creates => $pycortex_path,
    user => $system_user,
    cwd => $pycortex_install_root,
	timeout => 10000
  } ->

  exec { "build-pycortex":
    command => "$env_path/bin/python setup.py develop",
    user => $system_user,
    cwd => $pycortex_path
  } ->

  # download default datastore.  thanks to git support for svn,
  # svn export is a handy way to download bare subdirectories of git repos.
  exec { "get-pycortex-datastore":
    command => "svn export --force $neurovault_data_repo/pycortex_datastore $pycortex_datastore",
    creates => "$pycortex_datastore/pycortex",
    path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    timeout => 0
  } ->

#  exec { 'chown_datastore':
#    command     => "chown -R $httpd_user.$httpd_user $pycortex_datastore",
#    onlyif      => "test -d $pycortex_datastore",
#    unless      => "test -f /vagrant/Vagrantfile",
#    path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
#  } ->

  # create/chown data dirs

  file { $data_dirs:
    owner => $httpd_user,
    group => $httpd_user,
    mode => 775,
    ensure => directory
  } ->

  # create config file

  #file { "$pycortex_datastore/pycortex/options.cfg":
  #  ensure => present,
  #  content => template('neurovault/pycortex_options.cfg.erb'),
  #  owner =>  $system_user,
  #  group => $httpd_user,
  #  mode => '664'
  #} ->

  file_line { "pycortex_option_filestore":
    path  => "$pycortex_datastore/pycortex/options.cfg",
    line  => "filestore = $pycortex_datastore/db",
    match => "^filestore\s*=.*$",
  } ->

  file_line { "pycortex_option_colormaps":
    path  => "$pycortex_datastore/pycortex/options.cfg",
    line  => "colormaps = $pycortex_datastore/colormaps",
    match => "^colormaps\s*=.*$",
  } ->

  # copy color maps

  exec { 'copy_colormaps':
    command     => "cp $pycortex_path/filestore/colormaps/* $pycortex_datastore/colormaps/",
    creates     => "$pycortex_datastore/colormaps/Accent.png",
  } ->


#  exec { 'chown_colormaps':
#    command     => "chown -R $httpd_user.$httpd_user $pycortex_datastore/colormaps",
#    onlyif      => "test -d $pycortex_datastore/colormaps",
#    unless      => "test -f /vagrant/Vagrantfile",
#    path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
#  } ->

  # configure settings

  file_line { "pycortex_datastore_setting":
    path  => "$app_path/neurovault/local_settings.py",
    line  => "PYCORTEX_DATASTORE = '$pycortex_datastore'",
    match => "^PYCORTEX_DATASTORE.*$",
  } ->

  file_line { "pycortex_resource_setting":
    path  => "$app_path/neurovault/local_settings.py",
    line  => "    ('pycortex-resources', '$pycortex_path/cortex/webgl/resources'),",
    match => "^\s*\(\'pycortex-resources\',.*$",
  }


}


