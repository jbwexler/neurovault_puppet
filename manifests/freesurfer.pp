define neurovault::freesurfer (
  $tmp_dir,
  $freesurfer_dl_path,
  $freesurfer_src,
  $freesurfer_installdir,
  $freesurfer_lic_email,
  $freesurfer_lic_id,
  $freesurfer_lic_key,
  $bash_config_loc,
  $system_user,
  $app_path,
  $neurovault_data_repo,
)

{

  # --install freesurfer

  package { 'tcsh':
    ensure => installed,
  } ->

  # tkregister2 dep
  package { 'libglu1-mesa':
    ensure => installed,
  } ->

  exec { 'dl_freesurfer':
      command => "wget $freesurfer_dl_path/$freesurfer_src",
      cwd => $tmp_dir,
      creates => "$tmp_dir/$freesurfer_src",
      timeout => 3600000,
      unless => "test -d $freesurfer_installdir/freesurfer"
  } ->

  exec { 'untar_freesurfer':
      command => "tar zxvf $tmp_dir/$freesurfer_src",
      cwd => $freesurfer_installdir,
      creates => "$freesurfer_installdir/freesurfer"
  } ->

  # - add file_lines to bash config

  file {"$bash_config_loc":
    ensure => present,
  } ->

  file_line { "freesurf_env1":
    path  => "$bash_config_loc",
    line  => "export FREESURFER_HOME=$freesurfer_installdir/freesurfer",
    match => "^export FREESURFER_HOME.*$"
  } ->

  file_line { "freesurf_env2":
    path  => "$bash_config_loc",
    line  => "export FS_FREESURFERENV_NO_OUTPUT=1",
    match => "^export FS_FREESURFERENV_NO_OUTPUT.*$"
  } ->

  file_line { "freesurf_env3":
    path  => "$bash_config_loc",
    line  => "source \$FREESURFER_HOME/FreeSurferEnv.sh",
    match => '^source \$FREESURFER_HOME.*$'
  } ->

  # -- freesurfer license file

  file {"$freesurfer_installdir/freesurfer/.license":
    ensure => present,
    mode => '0600',
    owner => $system_user,
    group => $system_user,
  } ->

  file_line { "freesurf_lic1":
    path  => "$freesurfer_installdir/freesurfer/.license",
    line  => "$freesurfer_lic_email",
    match => "^$freesurfer_lic_email.*$"
  } ->

  file_line { "freesurf_lic2":
    path  => "$freesurfer_installdir/freesurfer/.license",
    line  => "$freesurfer_lic_id",
    match => "^$freesurfer_lic_id.*$"
  } ->

  file_line { "freesurf_lic3":
    path  => "$freesurfer_installdir/freesurfer/.license",
    line  => "$freesurfer_lic_key",
    match => "^\s.*$freesurfer_lic_key.*$"
  } ->

  # place correct freesurfer path in settings.py
  file_line { "freesurfer_home_setting":
    path  => "$app_path/neurovault/settings.py",
    line  => "os.environ[\"FREESURFER_HOME\"] = \"$freesurfer_installdir/freesurfer\"",
    match => "^os\.environ\[\"FREESURFER_HOME\"\] =.*$",
  } ->

  exec { "get-brain-nii":
    command => "svn export $neurovault_data_repo/freesurfer/brain.nii.gz $freesurfer_installdir/freesurfer/subects/fsaverage/mri/brain.nii.gz",
    creates => "$freesurfer_installdir/freesurfer/subects/fsaverage/mri/brain.nii.gz",
  }


}


