#!/bin/sh

cd /etc/puppet/modules/neurovault
#gem install puppet-module
sh install_deps.sh
puppet apply --verbose confs/nvault.pp &> ~/puppet.out
