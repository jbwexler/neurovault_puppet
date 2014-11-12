define neurovault::pycortex (
  $tmp_dir,
  $env_path,
  $system_user,
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
  ]

  # subversion is used to export file resources from github
  package { "subversion":
    ensure => installed,
  } ->

  # manually install pycortex (pip packaging is broken)
  exec { "clone-pycortex":
    command => "git clone -b $pycortex_branch $pycortex_repo",
    creates => $pycortex_path,
    user => $system_user,
    cwd => $pycortex_install_root
  } ->

  exec { "build-pycortex":
    command => "$env_path/bin/python setup.py develop",
    user => $system_user,
    cwd => $pycortex_path
  } ->

  # download default datastore.  thanks to git support for svn,
  # svn export is a handy way to download bare subdirectories of git repos.
  exec { "get-pycortex-datastore":
    command => "svn export $neurovault_data_repo/pycortex_datastore $pycortex_datastore",
    creates => $pycortex_datastore,
  } ->

  # create/chown data dirs

  file { $data_dirs:
    owner => "www-data",
    group => "www-data",
    mode => 775,
    ensure => directory
  } ->

  # create config file

  file { "$pycortex_datastore/pycortex/options.cfg":
    ensure => present,
    content => template('neurovault/pycortex_options.cfg.erb'),
    owner =>  $system_user,
    group => 'www-data',
    mode => '664'
  } ->

  # copy color maps

  exec { 'copy_colormaps':
    command     => "cp $pycortex_path/filestore/colormaps/* $pycortex_datastore/colormaps/",
    creates     => "$pycortex_datastore/colormaps/Accent.png",
  } ->

  exec { 'chown_colormaps':
    command     => "chown -R www-data.www-data $pycortex_datastore/colormaps",
    onlyif      => "test -d $pycortex_datastore/colormaps",
    path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  } ->

  # configure settings

  file_line { "pycortex_datastore_setting":
    path  => "$app_path/neurovault/settings.py",
    line  => "PYCORTEX_DATASTORE = '$pycortex_datastore'",
    match => "^PYCORTEX_DATASTORE.*$",
  } ->

  file_line { "pycortex_resource_setting":
    path  => "$app_path/neurovault/settings.py",
    line  => "('pycortex-resources', '$pycortex_path/cortex/webgl/resources')",
    match => "^\(\'pycortex-resources\',.*$",
  }


}


