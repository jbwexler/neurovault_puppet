define neurovault::feat (
  $app_path,
  $env_path,
  $system_user,
  $provtoolbox_config_loc,
  $provtoolbox_url,
  $provtoolbox_filepath,
  $provtoolbox_zipname,
  $prov_repo_url,
  $nidmresults_repo_url,
  $nidmresults_branch,
  $nidmfsl_repo_url,
  $nidmfsl_branch,
)

{

  $lib_install_root = "$env_path/lib"

  package { 'default-jre':
    ensure => installed,
  } ->

  package { 'unzip':
    ensure => installed,
  } ->

  file {"$provtoolbox_config_loc":
    ensure => present,
    content => "export PATH=\"$lib_install_root/provToolbox/bin:\$PATH\"",
  } ->

  exec { 'dl_provtoolbox':
    command => "wget -O $provtoolbox_zipname $provtoolbox_url?filepath=$provtoolbox_filepath",
    cwd => $lib_install_root,
    creates => "$lib_install_root/$provtoolbox_zipname",
    timeout => 3600000,
    user => $system_user,
  } ->

  exec { 'unzip_provtoolbox':
    command => "unzip $lib_install_root/$provtoolbox_zipname",
    cwd => $lib_install_root,
    creates => "$lib_install_root/provToolbox",
    user => $system_user,
  } ->

  # manually install packages under dev.

  exec { "clone-prov":
    command => "git clone $prov_repo_url",
    creates => "$lib_install_root/prov",
    user => $system_user,
    cwd => $lib_install_root,
    timeout => 10000
  } ->

  exec { "build-prov":
    command => "$env_path/bin/python setup.py develop",
    user => $system_user,
    cwd => "$lib_install_root/prov",
  } ->

  exec { "clone-nidmresults":
    command => "git clone -b $nidmresults_branch $nidmresults_repo_url",
    creates => "$lib_install_root/nidmresults",
    user => $system_user,
    cwd => $lib_install_root,
    timeout => 10000
  } ->

  exec { "build-nidmresults":
    command => "$env_path/bin/python setup.py develop",
    user => $system_user,
    cwd => "$lib_install_root/nidmresults",
  } ->

  exec { "clone-nidmfsl":
    command => "git clone -b $nidmfsl_branch $nidmfsl_repo_url",
    creates => "$lib_install_root/nidm-results_fsl",
    user => $system_user,
    cwd => $lib_install_root,
    timeout => 10000
  } ->

  exec { "build-nidmfsl":
    command => "$env_path/bin/python setup.py develop",
    user => $system_user,
    cwd => "$lib_install_root/nidm-results_fsl",
  } ->

  # provtoolbox exec path
    file_line { "provtoolbox_file_path":
      path  => "$app_path/neurovault/local_settings.py",
      line  => "os.environ[\"PATH\"] += os.pathsep + '$lib_install_root/provToolbox/bin'",
      match => "^os\.environ\[\"PATH\"\] =.*$",

  }

}


