####Additional notes re: GUI VM use, etc (WIP)

### Extension Pack:

I also installed the "VirtualBox Extension Pack," because I noticed a lot of the functionality under Settings had a note that basically said "this is only available with the extensions."  For example, to enable the remote display, the extensions were needed.  This is probably taken care of internally by Vagrant (the software we are going to use to run virtualbox) but I like to be extra careful.

- [Download the extensions](http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html#extpack)
- Check your version of virtual box under Help ==> About Virtualbox
- Click on the link for the extensions for your version
- It will open up with virtual box, and complete the install

### File Sharing: 
We will possibly want to move images from the local machine to the virtual machine. Uncomment this line (line 42) to specify the folder to share.  The first folder is on your local machine, the second is on the virtual machine.

    # config.vm.synced_folder "/home/vanessa/Packages/vagrantbox/data", "/data"
    to
    config.vm.synced_folder "/home/vanessa/Packages/vagrantbox/data", "/data"

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

---------------------------
### Clean Up
You should first delete the files in your temporary directory to conserve space, especially the freesurfer download, which is massive.  Or restart the VM:  `vagrant reload`.

    sudo rm /tmp/freesurfer-Linux-centos4_x86_64-stable-pub-v5.3.0.tar.gz

### Start the server
You can use your browser of choice to see the web interface, I chose to install firefox:

    sudo apt-get install firefox

And then started it up with an "&" to allow continued typing in the terminal (if desired):

    firefox &

Now we can start the NeuroVault (django) server!

    cd /opt/nv-env/NeuroVault
    python manage.py runserver

You will see that the development server is started at localhost on port 8000.  If you started your ssh with the display forwarding (`vagrant ssh -- -Y`) you should be able to open up firefox and go to localhost:8000.  This is what I did, and ssh'd into the machine from another terminal to have the processes in separate windows.  Firefox spits out a lot of junk to the window and I didn't want that continually interrupting me.

