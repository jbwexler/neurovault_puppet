#!/bin/sh
apt-get --assume-yes install git
cd /etc/puppet/modules/neurovault
puppet module install puppetlabs/postgresql
puppet module install puppetlabs/stdlib
puppet module install puppetlabs-apache
puppet module install jfryman/nginx

git clone https://github.com/Adcade/puppet-uwsgi.git /etc/puppet/modules/uwsgi
git clone git://github.com/stankevich/puppet-python.git /etc/puppet/modules/python
