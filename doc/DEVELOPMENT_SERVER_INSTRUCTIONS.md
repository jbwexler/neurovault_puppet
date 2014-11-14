# NeuroVault Development Server Setup
## Install Virtualbox
First install virtualbox:

sudo pip install virtualbox
(or here for different OS: https://www.virtualbox.org/wiki/Downloads)

I also installed the "VirtualBox Extension Pack," because I noticed a lot of the functionality under Settings had a note that basically said "this is only available with the extensions."  For example, to enable the remote display, the extensions were needed.  This is probably taken care of internally by Vagrant (the software we are going to use to run virtualbox) but I like to be extra careful.

- [Download the extensions](http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html#extpack)
- Check your version of virtual box under Help ==> About Virtualbox
- Click on the link for the extensions for your version
- It will open up with virtual box, and complete the install

## Install Vagrant
We are going to install "Vagrant," a front end to VirtualBox that is much easier than VirtualBox itself.

- [Install Vagrant](https://www.vagrantup.com/downloads)
- create a Vagrant project directory somewhere and enter it

Tell Vagrant to make an Ubuntu 14 64bit virtual machine:

    mkdir vagrantbox
    cd vagrantbox
    vagrant init ubuntu/trusty64


There will now be a Vagrantfile in this directory.  Edit it.  We want to uncomment a few things:

### Network: 
Uncomment this line (line 27) and save the file:

    # config.vm.network "private_network", ip: "192.168.33.10"   
    to
    config.vm.network "private_network", ip: "192.168.33.10" 

This means that the ip address "192.168.33.10." will be your virtual machine's address.  I didn't actually test or use this.

### File Sharing: 
We will possibly want to move images from the local machine to the virtual machine. Uncomment this line (line 42) to specify the folder to share.  The first folder is on your local machine, the second is on the virtual machine.

    # config.vm.synced_folder "/home/vanessa/Packages/vagrantbox/data", "/data"
    to
    config.vm.synced_folder "/home/vanessa/Packages/vagrantbox/data", "/data"


### Memory:
You will probably want to increase the amount of memory allocated to the machine, and so you should uncomment these lines (48,53,54):

    config.vm.provider "virtualbox" do |vb|
    #   # Don't boot with headless mode
    #   vb.gui = true
    #
    #   # Use VBoxManage to customize the VM. For example to change memory:
     vb.customize ["modifyvm", :id, "--memory", "8000"]    
    end

Exit from the editor, and create the directory for your data:

    mkdir /home/vanessa/Packages/vagrantbox/data

And note that I changed "1024" to "8000."  Now start up the virtual machine:

    vagrant up

(Note that if you ever need to restart the vm with a change to the config file having already done vagrant up, you should do vagrant reload).

When the machine is booted, time to log in! Your user name is 'vagrant' and you have sudo privileges with no password when logging in from vagrant.  Note that if you log in via virtual box, or via the gui, your password would be "vagrant" as well.  If you just do `vagrant ssh` you will log in via ssh.  But we also want to pass an additional variable to enable display forwarding to our machine, like this: `vagrant ssh -- -Y`

Here is your data folder:

    cd /data

-------
## Install NeuroVault-Puppet
Think of puppet like an "automation" system - kind of like an image, but more advanced.  I can create a server with my specific configuration, save a puppet module, and then deploy it to new machines.  The environment for NeuroVault is going to be installed similarity, via puppet. Follow the instructions [here](https://github.com/NeuroVault/neurovault_puppet). The server that is mentioned is our Vagrant server.

Make sure that you do the install with sudo, or else you won't be able to create folders and such.  The only errors that I saw were related to puppet modules already being installed.

*Troubleshooting:* 
If at some point the repository is not clone-able, or if you have trouble, you can always download and unzip.  I tried creating a few virtual machines, and for some reason, I ran into this issue with a different OS (I am not sure why). Here is how to get around it:  
If you cannot clone the repository, just grab the zip file instead:

    sudo apt-get install unzip
    wget https://github.com/NeuroVault/neurovault_puppet/archive/master.zip
    unzip master.zip
    mv neurovault_puppet /etc/puppet/modules/neurovault
    cd /etc/puppet/modules/neurovault

I would advise to not move forward if you don't have git working.  It's sort of an essential thing.  Once you do sudo sh do_install.sh, you can go back to working / coding on something else for a while.  It takes a little time to do all the setup.

---------------------------
### Clean Up
You should first delete the files in your temporary directory to conserve space, especially the freesurfer download, which is massive.

    sudo rm /tmp/freesurfer-Linux-centos4_x86_64-stable-pub-v5.3.0.tar.gz

----------------------------
### Install Python Modules
These python modules should (possibly) be installed / integrated into the puppet, but it's just as easy to install them separately. Go to where NeuroVault is installed:

    cd /opt/nv-env

I like using pip to install things:

    wget https://bootstrap.pypa.io/get-pip.py
    sudo python get-pip.py

The requirements.txt file can be used to install (most) requirements for NeuroVault:

    sudo pip install -r /opt/nv-env/NeuroVault/requirements.txt 

I ran into an error when it hit Cython, so I installed it manually (and if pip doesn't work you can download and compile from source, but pip worked for me):

    sudo pip install Cython

Then I did it again:

    sudo pip install -r /opt/nv-env/NeuroVault/requirements.txt 

and unfortunately ran into issues with pycortex both via the requirements.txt and pip.

> "UnicodeDecodeError: 'ascii' codec can't decode byte 0xe2 in position 44: ordinal not in range(128)*

This was resolved by installing from source.  Note that downloading took quite some time:

    git clone https://github.com/gallantlab/pycortex
    cd pycortex
    sudo python setup.py install
    cd ..
    rm -rf pycortex

Then I did this one more time to make sure we had everything:

    sudo pip install -r /opt/nv-env/NeuroVault/requirements.txt 

Everything worked for me with the above.  If you are having trouble and need to look at the output, remember you can output the terminal text to a file 

    sudo pip install -r NeuroVault/requirements.txt >> output.txt

### Start the server
You can use your browser of choice to see the web interface, I chose to install firefox:

    sudo apt-get install firefox

And then started it up with an "&" to allow continued typing in the terminal (if desired):

    firefox &

Now we can start the NeuroVault (django) server!

    cd /opt/nv-env/NeuroVault
    python manage.py runserver

You will see that the development server is started at localhost on port 8000.  If you started your ssh with the display forwarding (`vagrant ssh -- -Y`) you should be able to open up firefox and go to localhost:8000.  This is what I did, and ssh'd into the machine from another terminal to have the processes in separate windows.  Firefox spits out a lot of junk to the window and I didn't want that continually interrupting me.

You should now be able to create a login, create a collection, and start testing NeuroVault!  Remember that to easily upload images, you can put them in the shared data folder on your local machine, and they will appear in /data!

![Cookie Collection](img/neurocookie.png "Cookie Collection")
