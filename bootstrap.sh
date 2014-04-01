#!/bin/bash

set -x

apt-get update

apt-get install -y git

git clone https://github.com/openstack-dev/devstack.git

# Creates a user called "stack" with unknown password
./devstack/tools/create-stack-user.sh

# Won't prompt for password because we're running as root
su stack --command /vagrant/run_stack.sh
