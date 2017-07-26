Traas (fork)
============

This is a fork from James Slagle's [Traas](https://github.com/slagle/traas),
reworked to support only
[TripleO-Quickstart (oooq)](https://github.com/openstack/tripleo-quickstart)
OpenStack deployments, opposed to the original Traas, which uses the
[tripleo-ci](https://github.com/openstack-infra/tripleo-ci) scripts to mimic
openstack-infra CI jobs. See also,
[OVB devmode](https://docs.openstack.org/tripleo-quickstart/latest/devmode-ovb.html).

The repository (hereafter just a 'fork') contains a set of Heat templates and
wrapper scripts around quickstart and oooq-warp scripts and inventory vars.

Just like original Traas, the fork could just be used when you have access to
an OpenStack cloud with Heat that you want to use for TripleO development with
quickstart playbooks/roles, and dithcing the tripleo-ci and even the
`quickstart.sh`/`oooq-warp.sh`, if you prefer casting `ansible-playbook` spells
directly upon your inventory. The placeholder script, what is invoked by
the Heat SoftwareDeployment, is located under the `scripts/traas-oooq.sh` path.

Note, provisioning of networks and routers, and basically calling the very
deployment steps, like running your ansible-playbooks for OpenStack, have yet
to be automated and remain manual steps. You may want to use the placeholder
script `scripts/traas-oooq.sh` to host them there.

The Heat templates are used to bring up an environment on top of existing
Neutron networks and routers of the host OpenStack cloud, like RDO cloud. It
connects the pre-created admin/public networks to an undercloud VM and
admin/cluster networks to overcloud VMs. And then triggers some
SoftwareDeployment resources on the undercloud node to execute a deployment job

See also
[deployed-server](https://docs.openstack.org/tripleo-docs/latest/install/advanced_deployment/deployed_server.html).

Tripleo-Quickstart based deployments
====================================

This is a WIP.
Use it like this::

  $ openstack --os-cloud rdo-cloud stack create foo \
  -t templates/traas-oooq.yaml \
  -e templates/traas-oooq-resource-registry.yaml \
  -e templates/example-environments/rdo-cloud-oooq-env.yaml \
  --wait
  $ # trigger your deployment manually or automatically with the placeholder

The main template is::

  templates/traas-oooq.yaml

The example environment is::

  templates/example-environments/rdo-cloud-oooq-env.yaml

Once the nodes are up, the main script that is triggered is::

	scripts/traas-oooq.sh

The script logs to `tripleo-root/traas-oooq.log` in the home directory of the
`centos` user.

You may want to pre-create a volume and save docker images for future use.
Define the ``volume_id`` to ensure the pre-created volume is mounted for
an undercloud node. Then, from that undercloud node containing docker images
(see the `overcloud-prep-containers` quickstart-extras role for details),
do a one time export steps, for example::

  # mkfs.ext4 -F /dev/vdb
  # echo "/dev/vdb /mnt/docker_images ext4 defaults 0 0" >> /etc/fstab
  # mkdir -p /mnt/docker_images
  # mount -a
  # docker save $(docker images -f dangling=false | \
  awk '/^docker\.io/ {print $1}' | sort -u) | gzip -6 \
  > /mnt/docker_images/tripleoupstream.tar
  # sync
  # umount /mnt/docker_images

From now on, consequent stacks will load the saved images from the given
``volume_id`` while running the undercloud cloud-init user script.

.. note:: Changing docker graph driver or remapping its userns will reset
  loaded docker images.

For overcloud nodes to access loaded images from a local registry, configure
the registry for undercloud node, like this::

  # docker pull registry
  # docker run -dit -p 8787:5000 --name registry registry
  # curl -s <ctl_plane_ip>:8787/v2/_catalog | python -mjson.tool

Where the ``ctl_plane_ip`` comes from the wanted quickstart-extras variables
and normally should be equal to the private undercloud ``local_ip`` address.
