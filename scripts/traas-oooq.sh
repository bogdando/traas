#!/bin/bash

set -eux

export TRIPLEO_ROOT=$HOME/tripleo-root
mkdir -p $TRIPLEO_ROOT

LOGFILE=$TRIPLEO_ROOT/traas-oooq.log
exec > >(tee -a $LOGFILE)
exec 2>&1

cd $TRIPLEO_ROOT

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export PRIMARY_NODE_IP=${PRIMARY_NODE_IP:-""}
export SUB_NODE_IPS=${SUB_NODE_IPS:-""}
#export SSH_OPTIONS=${SSH_OPTIONS:-'-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=Verbose -o PasswordAuthentication=no -o ConnectionAttempts=32 -i ~/.ssh/id_rsa'}
#export TRIPLEO_CI_REMOTE=${TRIPLEO_CI_REMOTE:-https://git.openstack.org/openstack-infra/tripleo-ci}
#export TRIPLEO_CI_BRANCH=${TRIPLEO_CI_BRANCH:-master}

#rpm -q git || sudo yum -y install git

#[ -d tripleo-ci ] || git clone -b $TRIPLEO_CI_BRANCH $TRIPLEO_CI_REMOTE
echo "$PRIMARY_NODE_IP" > /tmp/PRIMARY_NODE_IP
echo "$SUB_NODE_IPS" > /tmp/SUB_NODE_IPS
#$TRIPLEO_ROOT/tripleo-ci/scripts/tripleo.sh --setup-nodepool-files
#TODO(bogdando) invoke ansible-playbook commands wrapped with oooq-warp
