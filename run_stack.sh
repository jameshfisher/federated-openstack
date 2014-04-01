#!/bin/bash

export DATABASE_PASSWORD=anothersecret
export RABBIT_PASSWORD=anothersecret
export SERVICE_TOKEN=anothersecret
export SERVICE_PASSWORD=anothersecret
export ADMIN_PASSWORD=anothersecret
export LDAP_PASSWORD=anothersecret
export MYSQL_PASSWORD=anothersecret

/home/vagrant/devstack/stack.sh
