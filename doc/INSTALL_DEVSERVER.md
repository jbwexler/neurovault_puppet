# NeuroVault Dev Server with Puppet, Vagrant, and VirtualBox
This guide will create an automated build of a NeuroVault dev environment (the VM) using three very useful tools:

+ **[Puppet](http://puppetlabs.com/puppet/what-is-puppet)** is a server configuration management system
+ **[Vagrant](http://vagrantup.com)** is a virtual machine provisioning abstraction layer
+ **[VirtualBox](https://www.virtualbox.org/)** is a freely available virtualization engine

#### 1. Install Virtualbox and Vagrant
Install VirtualBox and Vagrant for your OS:

+ https://www.vagrantup.com/downloads
+ https://www.virtualbox.org/wiki/Downloads

#### 2. Setup A Vagrant project directory
+ Create, then enter a new directory on your computer (the Host) that will contain your Vagrant project:
    ```
    mkdir -p ~/vms/neurovault
    cd ~/vms/neurovault
    ```

    _This directory will contain all project resources:  Git-tracked project source code, project media, server configuration manifests, and VM configuration._

+ Clone the NeuroVault puppet repository (this repo) to your vagrant directory:

    ```
    git clone https://github.com/NeuroVault/neurovault_puppet.git
    ```

+ Copy the Vagrantfile for Virtualbox to the root of the project directory:
    ```
    cp neurovault_puppet/confs/Vagrantfile.virtualbox Vagrantfile
    ```

+ _Optional_: Edit the Vagrantfile and customize it to your needs.  (There is usually no need to modify this.)
    - The default config will use the simplest networking and file sharing option available for VirtualBox (Port Forwarding, and Rsync).  The options should work on any system that can use Vagrant.
    - See the detailed comments in the [Vagrantfile](../Vagrantfile.virtualbox) for possible customization options.

#### 3. Edit Puppet configuration
Edit [confs/nvault.pp](../confs/nvault.pp) to configure NeuroVault for installation.  Only a few settings require changes:
+`gmail_login_str` to enable for outgoing mail
+`skip_freesurfer` to choose if Freesurfer will be installed
+Freesurfer license key (3 lines).
 
See the comments in the config file for details.

__Note__:  If you don't need a functional outgoing mailer or Freesurfer, you can simply set `skip_freesurfer => true` and proceeed to step 4.  (Pycortex will not be able to generate 3D views without Freesurfer.)

```ruby
    # Gmail SMTP setting:  Enter a Gmail username and password in this format
    #  to specify a Google account to use for the server's outgoing mail.  You
    #  can create an account specifically for this purpose, or use an existing
    #  personal gmail account.
    #
    # Note:  When creating a new Google account to use for outgoing SMTP,
    #  you'll need to log in, send an email, and receive an email as a normal
    #  web user before the account can be used programatically.

    gmail_login_str => "you@gmail.com",

    # Freesurfer license settings.  Freesurfer requires seperate user
    #  registration as non-free software.  Go to
    #  https://surfer.nmr.mgh.harvard.edu/registration.html to register for a
    #  free Freesurfer license key.  The three lines of the license file you
    #  receive in the email are placed into the following variables.  Note
    #  that the actual license string of encrypted characters contains a
    #  leading space.

    # Set this to 'True' to skip Freesurfer altogether:
    skip_freesurfer => false,

    freesurfer_lic_email => "you@email.net",
    freesurfer_lic_id => "00000",
    freesurfer_lic_key => " 000000000", # leading space then 13char key
```

#### 4. Vagrant Up
Now, we're ready to launch the VM.  Vagrant and Puppet will create a fully automated installation.  From your Vagrant project directory, enter:

    vagrant up

The installation will take anywhere from 30 minutes to 3 hours, depending on performance, network conditions, and whether Freesurfer will be installed (4GB).

#### 5. Using the VM

Vagrant will inform you when the installation is complete.

##### Accessing the VM:

+ To SSH into your VM, type `vagrant ssh`.
+ Note:  Everything is done as the `vagrant` user account.
+ To access the site, go to `http://localhost:8000` in your Host OS browser.

##### File locations:

  **Django App**: Your python environment and NeuroVault git working repositories will be located at `~/vms/neurovault/nv_env` on your host machine.  You can develop from this location, and changes will be synced to the VM.

  **Image Data**:  The site's image data directory will be served from `~/vms/neurovault/image_data` on the Host OS.

  **Pycortex Data:** The site's pycortex datastore will be served from `~/vms/neurovault/pycortex_data` on the Host OS.  


##### Django Devserver:
The system is deployed in basic production configuration by default, with Nginx and uwsgi running.  To run and debug Neurovault with the Django dev server, do the following:

+ Stop Nginx and uwsgi:

    ```
    sudo service nginx stop
    sudo service uwsgi stop
    ```

+ Navigate to the NeuroVault virtual environment and activate it:

    ```
    cd /opt/nv_env/
    source bin/activate
    ```

+ Enter the Django root dir:

    ```
    cd NeuroVault
    ```

+ Start the Dev server:

    ```
    ./manage.py runserver
    ```

+ To access the running Dev server, go to `http://localhost:8001` in your Host OS Browser (Port 8001 is used for the devserver, and 8000 is used for Nginx.)

#### 6. Complete!
You should now be able to create a login, create a collection, and start testing NeuroVault! :shipit:

![Cookie Collection](img/neurocookie.png "Cookies!")
