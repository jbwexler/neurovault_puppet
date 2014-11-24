### Python environment manual installation notes (WIP)
If Puppet returns errors during installation, look here for notes about manually building the python virtualenv for NeuroVault:

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
