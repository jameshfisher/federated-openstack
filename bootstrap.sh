#!/bin/bash

set -x

apt-get update

apt-get install -y git

# Clone to /home/vagrant/devstack
git clone https://github.com/openstack-dev/devstack.git

# https://github.com/kwss/keystone/blob/kent-federated-april/federated-docs/devstack-README

apt-get install libxmlsec1-dev
apt-get install -y python-setuptools
apt-get install -y libxml2-dev
pip install dm.xmlsec.binding

# Clone to /home/vagrant/keystone
git clone --branch kent-federated-april https://github.com/kwss/keystone.git

# 2. Modify the stackrc script with the correct keystone repository:

# KEYSTONE_REPO=${KEYSTONE_REPO:-${GIT_BASE}/openstack/keystone.git}
# KEYSTONE_BRANCH=${KEYSTONE_BRANCH:-master}

# KEYSTONE_REPO=https://github.com/kwss/keystone.git
# KEYSTONE_BRANCH=kent-federated-april

perl -p -i -e \
  's/KEYSTONE_REPO\=\$\{KEYSTONE_REPO\:\-\$\{GIT_BASE\}\/openstack\/keystone\.git\}/KEYSTONE_REPO=https\:\/\/github\.com\/kwss\/keystone\.git/g' \
  ~/devstack/stackrc

perl -p -i -e \
  's/KEYSTONE_BRANCH\=\$\{KEYSTONE_BRANCH\:\-master\}/KEYSTONE_BRANCH\=kent\-federated\-april/g' \
  ~/devstack/stackrc

# 3. Modify the libs/keystone script so that the following line:
# cp -p $KEYSTONE_DIR/etc/keystone.conf.sample $KEYSTONE_CONF
# looks like:
# cp -p /home/vagrant/keystone/federated-docs/example-keystone.conf
/home/vagrant/keystone/federated-docs/example-keystone.conf $KEYSTONE_CONF

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
/home/vagrant/keystone/federated-docs/example-keystone.conf
# to point to your request signing key if
#    SAML Identity providers will be used, this is specified in the following
#    section of the config file:

# requestSigningKey = /Users/kwss2/test/keystone/cert/privkey.pem
# to
# requestSigningKey = /home/vagrant/.ssh/keys/keystone_cert_privkey.pem

perl -p -i -e \
  's/\/Users\/kwss2\/test\/keystone\/cert\/privkey\.pem/\/home\/vagrant\/\.ssh\/keys\/keystone_cert_privkey\.pem/g' \
  /home/vagrant/keystone/federated-docs/example-keystone.conf

# Creates a user called "stack" with unknown password
./devstack/tools/create-stack-user.sh

# stack user needs write access to some stuff in the repo
chown -R stack:stack devstack

# Won't prompt for password because we're running as root
su stack --command /vagrant/run_stack.sh
