Puppet module for installing NeuroVault
=================

This module is intended for Puppet standalone installation of [NeuroVault](https://github.com/chrisfilo/NeuroVault), a Python web application for storing, sharing and viewing unthresholded brain activation maps.

###Installation Instructions:

1. Before you begin, create a server or virtual machine with __Ubuntu 14 Server 64-bit__.  You don't need to manually install any software on your system or VM, except `openssh-server` if you want to use ssh to log into your virtual machine.
 
Configure host name and networking.  For an production deployment, perform server hardening for your environment as needed.  

Be sure to have an account with administrative access (sudo).

Note:  Its not recommended to use this module if you already are using Nginx or Postgresql, since your existing configuration might be changed.  Use this tool as  a basis for a manual install in your configured environment.

2. Install Puppet, Git and Ruby packages, and update your operating system:
        
    ```
    sudo apt-get install git ruby puppet
    sudo apt-get update
    sudo apt-get -u upgrade
    ```

3. Become root.  Install the NeuroVault puppet module to the default puppet module location, and navigate to the module in your shell:
    
    ```
    sudo su -
    git clone https://github.com/NeuroVault/neurovault-puppet.git /etc/puppet/modules/neurovault
    cd /etc/puppet/modules/neurovault
    ```

4) Edit `/etc/puppet/modules/confs/nvault.pp` with settings to match your desired server environment.  The configurable values are described in the inline comments below:

_Important_: Most variables can be left with the default values.  The settings variables that must be modified are listed separately at the top of the configuration file.

_Also Important_:  Don't use empty strings for settings you don't need.  Leave the provided dummy value, or use `'none'`
    
```ruby

neurovault::main { 'nvault-install':
    
    ############################################################
    # SECTION 1: REQUIRED settings                             #
    # These options must be specified to perform installation. #
    ############################################################

    # An existing user account (and matching group) to be used for ownership 
    # of the NeuroVault application and environment.

    # For a production install, manually create and use an un-privileged
    #  account normal account such as 'neurovault'.  For dev, its usually 
    #  convenient to use your primary user account.
    system_user => "username",

    # Gmail SMTP setting:  Enter a Gmail username and password in this format 
    #  to specify a Google account to use for the server's outgoing mail.  You 
    #  can create an account specifically for this purpose, or use an existing 
    #  personal gmail account. 
    #
    # Note:  When creating a new Google account to use for outgoing SMTP,
    #  you'll need to log in, send an email, and receive an email as a normal 
    #  web user before the account can be used programatically.

    gmail_login_str => "system-notify@infocortex.com:themailpasswd",

    # Freesurfer license settings.  Freesurfer requires separate user 
    #  registration as it is non-free software.  Go to 
    #  https://surfer.nmr.mgh.harvard.edu/registration.html to register for a 
    #  free Freesurfer license key.  The three lines of the license file you
    #  receive in the email are placed into the following variables.  Note 
    #  that the actual license string of encrypted characters contains a 
    #  leading space.

    freesurfer_lic_email => "your_email_address@yourdomain.com",
    freesurfer_lic_id => "00000",
    freesurfer_lic_key => " 0000000000000", # leading space then 13char key.

    # The full URL of your Neurovault site, i.e. http://neurovault.org or 
    #  http://localhost. You can use the default. This should be consistent 
    #  with your host_name (see below):
    app_url => "http://neurovault-dev.local",
    
    # The fully-qualified hostname of your server, localhost.localdomain or 
    #  server.yourdomain.com, etc.
    # The HTTP server, Nginx or Apache, relies on name-based virtual hosting, 
    #  so working DNS name resolution is recommended.  Use real DNS, or 
    #  configure /etc/hosts on your development machine to point this host 
    #  name to the IP address of your VM/server.
    # Note:  a fully-qualified hostname contains a host name and a domain name 
    #  seperated by a dot.  It can be anything, such as foo.local

    host_name => "neurovault-dev.local",

    #################################################################
    # SECTION 2: Optional                                           #
    # These can be changed to customize the installation, but       #
    # the defaults can be used without a problem.                   #
    #################################################################

    # Path to an existing directory with a backup copy of NeuroVault main 
    #  images directory.  If this path exists, the module will copy the data 
    #  into the server's installed images.  If starting with a fresh 
    #  installation, this can be ignored.
    private_media_existing => "/path/to/neurovault_testdata/image_data",

    # Path to an existing SQL dump file with an existing version of the 
    #  NeuroVault database.  Use this to populate the database with existing 
    #  data.  If starting with a fresh installation, this can be ignored.
    db_existing_sql => "/path/to/database/dump.sql"

    # location of Python virtual environment.
    # Puppet will install the python environment at this location.
    env_path => "/opt/nv-env",
    
    # Postgresql database settings.
    # Puppet will install and configure Postgresql automatically with the 
    #  provided database name, user name, and password.
    db_name => "neurovault",
    db_username => "neurovault",
    db_userpassword => "neurovault",
    
    # An existing directory for temporary downloads during installation:
    tmp_dir => "/tmp",
    
    # The location of a shell environment config, /etc/profile.d is standard 
    #  on Ubuntu.  This shouldn't need to be changed unless you use non-
    #  standard bash environment customization scripts.
    bash_config_loc => "/etc/profile.d/freesurfer.sh",

    # The location of the NeuroVault git repository:
    repo_url => "https://github.com/NeuroVault/NeuroVault.git",
    # The branch to use, in case you want to test a feature branch from a 
    #  fresh install, otherwise always 'master':
    repo_branch => "master",
    
    # Link to the Github repository that contains the NeuroVault default data.
    # Note: the URL is formatted for Github SVN support: 
    #  (`repo.git` becomes `repo/trunk`)
    neurovault_data_repo => "https://github.com/NeuroVault/neurovault_data/trunk"

    # The NeuroDebian repository link, sources.list, and apt key source  for 
    #  Ubuntu 14.  No need to modify this.
    neurodeb_list => "http://neuro.debian.net/lists/trusty.de-m.libre",
    neurodeb_sources => "/etc/apt/sources.list.d/neurodebian.sources.list",
    neurodeb_apt_key => "hkp://pgp.mit.edu:80 2649A5A9",
    
    # The installation module supports deploying NeuroVault with two web server
    #  /WSGI platforms: Nginx/uwsgi or alternately Apache/mod_wsgi.  
    # Use `nginx` unless you have a very specific reason to use `apache`, 
    #  which is deprecated.
    http_server => "nginx"
    
    # Dropbox Backup settings
    #  storage module, usually dropbox_storage.  The backup module also 
    #  supports AWS.  Configure this with correct settings to use the dropbox 
    #  backups.
    
    # The installation module will create a secrets.py file that has secure permissions.
    dbbackup_storage =>"dbbackup.storage.dropbox_storage",
    dbbackup_tokenpath =>"<local_tokens_filepath>",
    dbbackup_appkey =>"<dropbox_app_key>",
    dbbackup_secret =>"<dropbox_app_secret>",

    # Start Django in Debug mode after initial installation?  This can be 
    #  useful to debug installation issues
    start_debug =>"true",

    #  Media / Private Media locations.
    private_media_root => "/opt/nv-env/image_data",
    private_media_url => "/media/images",

    # Freesurfer download source and settings
    freesurfer_dl_path => "ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/5.3.0",
    freesurfer_src => "freesurfer-Linux-centos4_x86_64-stable-pub-v5.3.0.tar.gz",
    freesurfer_installdir => "/opt",

    #Pycortex Settings
    pycortex_repo => "https://github.com/gallantlab/pycortex.git",
    pycortex_branch => "master",
    pycortex_datastore => "/opt/nv-env/pycortex-data",
}
```


5) After configuration is completed, install the Neurovault puppet module dependencies with this script:

```
sh install_deps.sh
```

6) Lastly, begin the installation.  The installation make take some considerable time to download compile the python modules and dependencies.

```
sh do_install.sh
```

###### Done!

You will now have a live NeuroVault installation at the location you've chosen.  By default, you can navigate to "http://neurovault-dev.local" . The application will be located under `/opt/nv-env` or the location you've chosen.

