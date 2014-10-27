Puppet module for installing NeuroVault
=================

This module is intended for Puppet standalone installation of [NeuroVault](https://github.com/chrisfilo/NeuroVault), a Python web application for storing, sharing and viewing unthresholded brain activation maps.

###Installation Instructions:


1. Before you begin, create a server or virtual machine with __Ubuntu 14 Server 64-bit__.  If you use a guided installation with installation media, you don't need to install any packages except `openssh-server`.  Configure host name, networking, and server hardening for your environment as needed.  Be sure to have an account with administrative access (sudo).


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
    
```ruby

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
    
    # The user account to be used for ownership of the NeuroVault application 
    # and environment. (If you use an existing user, use an un-privileged account
    # for a production installation):
    system_user => "grivera",
    
    # An existing directory for temporary downloads during installation:
    tmp_dir => "/home/grivera/downloads",
    
    # The location of the NeuroVault git repository:
    repo_url => "https://github.com/chrisfilo/NeuroVault.git",
    
    # The NeuroDebian repository link, sources.list, and apt key source  for Ubuntu 14.
    # (These will only need to change to use an older/different OS version):
    
    neurodeb_list => "http://neuro.debian.net/lists/trusty.de-m.libre",
    neurodeb_sources => "sudo tee /etc/apt/sources.list.d/neurodebian.sources.list",
    neurodeb_apt_key => "hkp://pgp.mit.edu:80 2649A5A9",
    
    # The installation module supports deploying NeuroVault with two web server/WSGI  
    # platforms for: Nginx/uwsgi or alternately Apache/mod_wsgi.  
    # Note: Use `nginx` unless you have a specific reason to use `apache`.
    http_server => "nginx"
    
    # Dropbox Backup settings
    # storage module, usually dropbox_storage.  The backup module also supports AWS.
    dbbackup_storage =>"dbbackup.storage.dropbox_storage",

    # The path to the secure token and app key, and app secret for dropbox backups.  The installation module will create a secrets.py file that has secure permissions.
    dbbackup_tokenpath =>"<local_tokens_filepath>",
    dbbackup_appkey =>"<dropbox_app_key>",
    dbbackup_secret =>"<dropbox_app_secret>",

    # Start Django in Debug mode after initial installation?  This can be useful to debug installation issues
    start_debug =>"true",

    #  Media / Private Media Settings.
    private_media_root => "/opt/nv-env/NeuroVault/image_data",
    private_media_url => "/media/images",
    private_media_existing => "/home/grivera/neurovault_testdata/image_data",
    media_root => "/opt/nv-env/NeuroVault/neurovault/media/",
    media_url => "/public/media/",  # must end in a trailing slash
    media_existing => "/home/grivera/neurovault_testdata/pub-media",

    # SMTP Settings
    gmail_login_str => "system-notify@infocortex.com:themailpasswd",

    # Freesurfer Settings
    freesurfer_dl_path => "ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/5.3.0",
    freesurfer_src => "freesurfer-Linux-centos4_x86_64-stable-pub-v5.3.0.tar.gz",
    freesurfer_installdir => "/opt",
    freesurfer_lic_email => "freesurfer_email@yourdomain.com",
    freesurfer_lic_id => "00000",
    freesurfer_lic_key => " fs_lic_passwd_", # note leading space.
    bash_config_loc => "/etc/profile.d/freesurfer.sh",

    #Pycortex Settings
    pycortex_repo => "https://github.com/gallantlab/pycortex.git",
    pycortex_branch => "master",
    pycortex_data_dir => "/opt/nv-env/NeuroVault/pycortex-newdata",
    pycortex_existing_subject => "/home/grivera/fsaverage",
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

