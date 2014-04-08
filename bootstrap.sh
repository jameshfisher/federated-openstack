#!/bin/bash

set -x
set -e

apt-get update

apt-get install -y git

# Clone to /home/vagrant/devstack
git clone https://github.com/openstack-dev/devstack.git

# Clone to /home/vagrant/keystone
git clone --branch kent-federated-april https://github.com/kwss/keystone.git

# The numbered points below are following:
# https://github.com/kwss/keystone/blob/kent-federated-april/federated-docs/devstack-README

# 1. Install dependency for SAML authentication module.
apt-get install -y libxmlsec1-dev
apt-get install -y python-setuptools
apt-get install -y libxml2-dev
pip install dm.xmlsec.binding

# 2. Modify the stackrc script with the correct keystone repository:
perl -p -i -e \
  's/KEYSTONE_REPO\=\$\{KEYSTONE_REPO\:\-\$\{GIT_BASE\}\/openstack\/keystone\.git\}/KEYSTONE_REPO=https\:\/\/github\.com\/kwss\/keystone\.git/g' \
  ~/devstack/stackrc
perl -p -i -e \
  's/KEYSTONE_BRANCH\=\$\{KEYSTONE_BRANCH\:\-master\}/KEYSTONE_BRANCH\=kent\-federated\-april/g' \
  ~/devstack/stackrc

# 3. Modify the libs/keystone script so that the following line:
perl -p -i -e \
  's/cp \-p \$KEYSTONE_DIR\/etc\/keystone\.conf\.sample \$KEYSTONE_CONF/cp \-p \/home\/vagrant\/keystone\/federated\-docs\/example\-keystone\.conf \$KEYSTONE_CONF/g' \
  ~/devstack/lib/keystone

# Generate private key for keystone
# /home/vagrant/.ssh/keys/keystone_cert_privkey.pem
ssh-keygen -t rsa \
  -C 'keystone@federated-openstack' \
  -N '' \
  -f /home/vagrant/.ssh/keys/keystone_cert_privkey.pem

# 4. Modify the example config file
# /home/vagrant/keystone/federated-docs/example-keystone.conf
# to point to your request signing key if
#    SAML Identity providers will be used, this is specified in the following
#    section of the config file:

perl -p -i -e \
  's/\/Users\/kwss2\/test\/keystone\/cert\/privkey\.pem/\/home\/vagrant\/\.ssh\/keys\/keystone_cert_privkey\.pem/g' \
  /home/vagrant/keystone/federated-docs/example-keystone.conf

# Creates a user called "stack" with unknown password
./devstack/tools/create-stack-user.sh

# stack user needs write access to some stuff in the repo
chown -R stack:stack devstack

# Won't prompt for password because we're running as root
su stack --command /vagrant/run_stack.sh
