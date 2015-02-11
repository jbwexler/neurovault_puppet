# Troubleshooting

Here are the general steps for restarting an attempt to configure the machine.

#### Delete (errored) machines
When the `vagrant up` doesn't work, before you try again, you need to do the following:

Clear the errored mounts (see below), and stop the machine and destroy it

      vagrant suspend
      vagrant destroy

Delete any temporary files

      sudo rm -rf .vagrant/

I am not sure if this is necessary, but I also deleted the mount folders that were created (eg, image_data, nv_env, and pycortex_data)

#### Clear the errored mounts
For all solutions below, before you try a fresh install (eg `vagrant up`) you need to delete the errored mount attempts, because they will remain in the system file and continue to trigger errors:

      sudo vim /etc/exports

You will see something along the lines of:

      # VAGRANT-BEGIN: 1000 9bfb8ce1-3a88-4173-a67e-7b70eff3e94e
      "/home/vanessa/Packages/vagrant/neurovault/neurovault_puppet" 192.168.33.10(rw,no_subtree_check,all_squash,anonuid=1000,anongid=wheel,fsid=399783149)
      "/home/vanessa/Packages/vagrant/neurovault/nv_env" 192.168.33.10(rw,no_subtree_check,all_squash,anonuid=1000,anongid=wheel,fsid=1116967821)
      "/home/vanessa/Packages/vagrant/neurovault/image_data" 192.168.33.10(rw,no_subtree_check,all_squash,anonuid=1000,anongid=wheel,fsid=3802941516)

Delete all the lines that were added by vagrant.


## Error: /etc/exports: bad anonuid

Mounting the file system requires that the user and group ids in the vagrant file are aligned with yours.  If you get this error:

  ==> default: Preparing to edit /etc/exports. Administrator privileges will be required...
  [sudo] password for yourname: 
  nfsd running
  exportfs: /etc/exports: 7: bad anonuid "anonuid=root"

This will lead to an errored install without mounted folders, which is impossible for developing. You have a few options to "workaround" this.


### Option 1: Mount with bindfs

Bindfs is a vagrant plugin that can be used to better handle mounting. You would first need to install on your machine:


      vagrant plugin install vagrant-bindfs


You would then want to change the mount points in your Vagrantfile to look along these lines (edit paths to where you want to mount on your local machine)

      #  Mount point for puppet modules
      config.vm.synced_folder "neurovault_puppet", "/mnt/etc/puppet/modules/neurovault", nfs:true, create:true
      config.bindfs.bind_folder "/mnt/etc/puppet/modules/neurovault", "/etc/puppet/modules/neurovault"

      #  Mount point of neurovault environment
      config.vm.synced_folder "nv_env", "/mnt/opt/nv_env", nfs:true, create:true
      config.bindfs.bind_folder "/mnt/opt/nv_env", "/opt/nv_env"

      #  Mount point of image datastore
      config.vm.synced_folder "image_data", "/mnt/opt/image_data", nfs:true, create:true
      config.bindfs.bind_folder "/mnt/opt/image_data", "/opt/image_data"

      #  Mount point of pycortex datastore
      config.vm.synced_folder "pycortex_data", "/mnt/opt/pycortex_data", nfs:true, create:true
      config.bindfs.bind_folder "/mnt/opt/pycortex_data", "/opt/pycortex_data"


Note that when you setup the server, there will be a message that bindfs is not installed, but it seems to install automatically.

### Option 2: Change the uid to numbers

The other option is to change the current setup, where it specifies user and group ids as `root` and `wheel` to ids that correspond with your user.  For example, here is what the default looks like:

      config.vm.synced_folder "neurovault_puppet", "/etc/puppet/modules/neurovault", type:"nfs", create:true, map_uid: 'root', map_gid: 'wheel' 

This seems to work well on Mac, but it did not work for some of our testers on linux (Ubuntu).  The workaround that did was looking up the user ids:

      $ id vanessa
      uid=1000(vanessa) gid=1000(vanessa) groups=1000(vanessa),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),108(lpadmin),124(sambashare)
      $ id root
      uid=0(root) gid=0(root) groups=0(root)

And then changing the line to:

      config.vm.synced_folder "neurovault_puppet", "/etc/puppet/modules/neurovault", type:"nfs", create:true, map_uid: '10000', map_gid: '10000'


## Uwsgi and nginx errors
The server should be active on your local machine at `192.168.33.10`, but sometimes you will get server errors and an ugly white screen.  It is good practice to always restart these servers with any changes, as this is a common fix to the problem:

      sudo service uwsgi restart
      sudo service nginx restart

If you need to debug, logs can be found at `/var/log/nginx' and '/var/log/uwsgi'. I'm not sure if this is useful, but sometimes deleting the neurovault.sock (and having a new one get generated) can help fix issues. I couldn't get it to delete, but moving seemed to work:

      mv neurovault.sock /home/vagrant/neurovault.sock.bak
      sudo service uwsgi restart
      sudo service nginx restart


### I just can't get the port forwarded
It's extremely annoying to have the forwarding not work to your local machine, but if you are desperate there is a workaround - to run the django server locally and view on a browser from within the VM (yes, I am wincing as I write this). First, when you ssh with vagrant, you want to make sure to enable X11 forwarding:

      vagrant ssh -- -Y
      source /opt/nv_env/bin/activate
      python /opt/nv_env/NeuroVault/manage.py runserver 8080

This will get the server running, manually. Now you should open a second terminal for firefox:

      vagrant ssh -- -Y
      sudo apt-get install firefox
      firefox

And going to localhost:8080 (or whatever port you have specified) will show the application. You would then need to have a third terminal to do command line stuffs (more wincing).


## Celery Errors
You should first see if you have celery, period

      which celery
      /usr/local/bin/celery

Is it running?

      celery status

And make sure that you also have the redis server working:

      redis-cli ping
      PONG

You can then try restarting celery and the tasks:

      sudo service neurovault-tasks restart
      sudo /etc/init.d/neurovault-tasks restart # This may be the same thing, another way
      sudo /etc/init.d/celeryev restart      

The best way to test your tasks is to start celery manually, which means that you can generate tasks in the web interface and see them complete successfully (or error out) in the window where you are running the server.

      ./manage.py celery worker -A neurovault.celery -l info -E --autoreload

## Task Errors

### Similarity does not exist
The similarity metric needs to be added manually, so if you have not done this, you will see this error:      

      Task neurovault.apps.statmaps.tasks.save_voxelwise_pearson_similarity[b4bc9dd0-a37c-4352-be65-74fe613c78b1] raised unexpected: DoesNotExist('Similarity matching query does not exist.',)

You should add it! You can open up a shell using manage.py, and copy the code from `scripts/add_pearson_similarity_metric.py`

      manage.py shell
      [copied code from scripts/add_pearson_similarity_metric


## NeuroVault missing relations, etc.
Sometimes the database is out of data, and you get errors that a relation is missing.  You should try making and doing migrations:

      /opt/nv_env/NeuroVault/manage.py makemigrations
      /opt/nv_env/NeuroVault/manage.py migrate


