Puppet module for installing NeuroVault
=================

This module is intended for Puppet standalone installation of [NeuroVault](https://github.com/chrisfilo/NeuroVault), a Python web application for storing, sharing and viewing unthresholded brain activation maps.

###Installation Instructions:


1. Before you begin, create a server or virtual machine with _Ubuntu 14 Server 64-bit _.  If you use a guided installation with installation media, don't install any packages except `openssh-server`.  Configure host name, networking, and perform server hardening for your environment as needed.  Be sure to have an account with administrative access (sudo).


2. Install Puppet, Git and Ruby packages, and update your operating system:
		
	```
	sudo apt-get install git ruby puppet
	sudo apt-get update
	sudo apt-get -u upgrade
	```

3. Become root.  Install the NeuroVault puppet module to the default puppet module location, and navigate to the module in your shell:

	```
	sudo su -
	git clone https://github.com/infocortex/neurovault-puppet.git /etc/puppet/modules/neurovault
	cd /etc/puppet/modules/neurovault
	```

4) Edit `/etc/puppet/modules/confs/nvault.pp` with settings to match your desired server environment.  The configurable values are described in the inline comments below:

```
neurovault::main { 'nvault-install':

  # location of Python virtual environment:
  env_path => "/opt/nv-env",

  # Postgresql database name:
  db_name => "neurovault",

  # Postgresql database user name:
  db_username => "neurovault",

  # Postgresql database password:
  db_userpassword => "neurovault",

  # The full URL of your Neurovault installation:
  app_url => "http://nvault.infocortex.de",

  # The fully-qualified hostname of your server:
  host_name => "nvault.infocortex.de",

  # The user account to be used for ownership of the NeuroVault application and environment.  If you use an existing user, use an un-privileged account for a production installation):
  system_user => "grivera",

  # An existing directory for temporary downloads during installation:
  tmp_dir => "/home/grivera/downloads",

  # The location of the NeuroVault repository
  repo_url => "https://github.com/chrisfilo/NeuroVault.git",

  # The NeuroDebian repository link, sources.list, and apt key source  for Ubuntu 14.  (These will only need to change to use an older/different OS version):

  neurodeb_list => "http://neuro.debian.net/lists/trusty.de-m.libre",
  neurodeb_sources => "sudo tee /etc/apt/sources.list.d/neurodebian.sources.list",
  neurodeb_apt_key => "hkp://pgp.mit.edu:80 2649A5A9",

 # The installation module supports deploying NeuroVault with two http/wsgi platforms:  __Nginx/uwsgi__ or __Apache/mod_wsgi__ and .  Use `nginx` unless you have a specific reason to use `apache`.
  http_server => "nginx"
}
```


5) Install the Neurovault puppet module dependencies with this script:

```
sh install_deps.sh
```

6) Lastly, begin the installation.  The installation make take some considerable time to download compile the python modules and dependencies.

```
sh do_install.sh
```

###### Done!

You will now have a live NeuroVault installation at the location you've chosen.  Have fun!

