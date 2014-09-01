neurovault::main { 'nvault-install':
  env_path => "/opt/nv-env",
  db_name => "neurovault",
  db_username => "neurovault",
  db_userpassword => "neurovault",
  app_url => "http://nvault.infocortex.de",
  host_name => "nvault.infocortex.de",
  system_user => "grivera",
  tmp_dir => "/home/grivera/downloads",
  repo_url => "https://github.com/chrisfilo/NeuroVault.git",
  neurodeb_list => "http://neuro.debian.net/lists/trusty.de-m.libre",
  neurodeb_sources => "sudo tee /etc/apt/sources.list.d/neurodebian.sources.list",
  neurodeb_apt_key => "hkp://pgp.mit.edu:80 2649A5A9",
  http_server => "nginx"
}
