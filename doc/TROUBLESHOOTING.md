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


## Uwsgi and nginx errors
The server should be active on your local machine at `192.168.33.10`, but sometimes you will get server errors and an ugly white screen.  It is good practice to always restart these servers with any changes, as this is a common fix to the problem:

      sudo service uwsgi restart

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

Make sure that you also have the redis server working:

      redis-cli ping
      PONG
      
Count jobs in celery:

      redis-cli llen celery
      
Check celery logs:

     cat /var/log/neurovault-tasks/celery.log

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
      >%run scripts/add_pearson_similarity_metric


## NeuroVault missing relations, etc.
Sometimes the database is out of data, and you get errors that a relation is missing.  You should try making and doing migrations:

      /opt/nv_env/NeuroVault/manage.py makemigrations
      /opt/nv_env/NeuroVault/manage.py migrate


