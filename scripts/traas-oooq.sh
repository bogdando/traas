#!/bin/bash

set -eux

#FIXME(bogdando) legacy from tripleo-ci nodepool related setup
export TRIPLEO_ROOT=$HOME/tripleo-root
mkdir -p $TRIPLEO_ROOT

LOGFILE=$TRIPLEO_ROOT/traas-oooq.log
exec > >(tee -a $LOGFILE)
exec 2>&1

cd $TRIPLEO_ROOT

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export PRIMARY_NODE_IP=${PRIMARY_NODE_IP:-""}
export SUB_NODE_IPS=${SUB_NODE_IPS:-""}
echo "$PRIMARY_NODE_IP" > /tmp/PRIMARY_NODE_IP
echo "$SUB_NODE_IPS" > /tmp/SUB_NODE_IPS

#NOTE(bogdando) here is the place to invoke your openstack deployment
#automation scripts

#TODO(bogdando) run ansible-playbook commands wrapped with oooq-warp to
#deploy things
