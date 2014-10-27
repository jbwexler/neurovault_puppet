define neurovault::pycortex (
  $tmp_dir,
  $env_path,
  $system_user,
  $app_path,
  $pycortex_repo,
  $pycortex_branch,
  $pycortex_data_dir,
  $pycortex_existing_subject,
)

{

  $pycortex_install_root = "$env_path/lib"
  $pycortex_path = "$env_path/lib/pycortex"

  $data_dirs = [
    $pycortex_data_dir,
    "$pycortex_data_dir/colormaps",
    "$pycortex_data_dir/db",
    "$pycortex_data_dir/pycortex",
    "$pycortex_data_dir/temp",
  ]

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

  # create data dirs

  file { $data_dirs:
    owner => "www-data",
    group => "www-data",
    mode => 775,
    ensure => directory
  } ->

  # create config file

  file { "$pycortex_data_dir/pycortex/options.cfg":
    ensure => present,
    content => template('neurovault/pycortex_options.cfg.erb'),
    owner =>  $system_user,
    group => 'www-data',
    mode => '664'
  } ->

  # populate fsaverage subject

  exec { 'move_fsaverage_sub':
    command     => "mv $pycortex_existing_subject $pycortex_data_dir/db/fsaverage",
    onlyif      => ["test -d $pycortex_existing_subject","test ! -d $pycortex_data_dir/db/fsaverage"],
    path            => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  } ->

  exec { 'chown_fsaverage_sub':
    command     => "chown -R www-data.www-data $pycortex_data_dir/db/fsaverage",
    onlyif      => "test -d $pycortex_data_dir/db/fsaverage",
    path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  } ->

  # copy color maps

  exec { 'copy_colormaps':
    command     => "cp $pycortex_path/filestore/colormaps/* $pycortex_data_dir/colormaps/",
    creates     => "$pycortex_data_dir/colormaps/Accent.png",
  } ->

  exec { 'chown_colormaps':
    command     => "chown -R www-data.www-data $pycortex_data_dir/colormaps",
    onlyif      => "test -d $pycortex_data_dir/colormaps",
    path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  } ->

  # configure in settings

  file_line { "pycortex_conf_home":
    path  => "$app_path/neurovault/settings.py",
    line  => "PYCORTEX_CONFIG_HOME = '$pycortex_data_dir'",
    match => "^PYCORTEX_CONFIG_HOME.*$",
  }

}


