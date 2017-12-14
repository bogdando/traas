Traas (fork)
============

This is a fork from James Slagle's [Traas](https://github.com/slagle/traas),
reworked to support only
[TripleO-Quickstart (oooq)](https://github.com/openstack/tripleo-quickstart)
OpenStack deployments, opposed to the original Traas, which uses the
[tripleo-ci](https://github.com/openstack-infra/tripleo-ci) scripts to mimic
openstack-infra CI jobs. See also:

* [OVB devmode](https://docs.openstack.org/tripleo-quickstart/latest/devmode-ovb.html)
* The original [Traas announce](http://lists.openstack.org/pipermail/openstack-dev/2017-February/112993.html)

The repository (hereafter just a 'fork') contains a set of Heat templates and
wrapper scripts around quickstart and oooq-warp scripts and inventory vars.

Just like original Traas, the fork could just be used when you have access to
an OpenStack cloud with Heat that you want to use for TripleO development with
quickstart playbooks/roles, and dithcing the tripleo-ci and even the
`quickstart.sh`/`oooq-warp.sh`, if you prefer casting `ansible-playbook` spells
directly upon your inventory. The placeholder script, what is invoked by
the Heat SoftwareDeployment, is located under the `scripts/traas-oooq.sh` path.

> **note**
>
> provisioning of admin network and routers, and basically calling the very
> deployment steps, like running your ansible-playbooks for OpenStack, have yet
> to be automated and remain manual steps. You may want to use the placeholder
> script `scripts/traas-oooq.sh` to host them there.

The Heat templates are used to bring up an environment on top of existing admin
Neutron network and routers of the host OpenStack cloud, like RDO cloud. It
connects the existing admin network and public networks to the undercloud VM.
The overcloud VMs do not have sec groups enabled and no floating IPs. It also
creates for undercloud and overcloud an isolated, non-routed cluster networks
of given CIDR ranges. Those are mostly needed to manipulate with bridges while
doing net config steps by t-h-t. Undercloud only needs this for all-in-one.

Finally, it triggers some SoftwareDeployment resources on the undercloud node to
execute a deployment job (nooped for now).

See also
[deployed-server](https://docs.openstack.org/tripleo-docs/latest/install/advanced_deployment/deployed_server.html).

Provisioning requirements
=========================

* A non admin tenant on the host OpenStack cloud, say RDO cloud.
* Create an admin and public networks and routers, e.g. per this
  [RDO cloud doc](https://docs.google.com/document/d/1bFEayAH7Mqi7zn7fpdMS3Zc-plOOnqoGqh7cDNjLxB8/edit#heading=h.2wr6dc75ub5y).
  Name it to match the example `templates/example-environments/rdo-cloud-oooq-env.yaml`
  file and/or modify the latter as needed, see the steps below. Note that the
  overcloud cluster network will be isolated, unrouted, without ports security
  and DHCP or router connections created.

> **note**
>
> Do not choose networks' subnets that would overlap with a subnet you plan
> to use for developing TripleO. The default subnet for TripleO is 192.168.24.0/24.
> So choose a subnet that does not overlap with this CIDR. Admin network is
> expected to be a '192.168.0.0/24'.

* Create a keypair in nova
* Clone this repo's **dev** branch and customize the
 `example-environments/rdo-cloud-env.yaml` file or another example as you want it.

Add a few default sec group rules:

    $ openstack --os-cloud rdo-cloud security group rule create \
      --ingress \
      --protocol tcp \
      default

    $ openstack --os-cloud rdo-cloud security group rule create \
      --ingress \
      --protocol udp \
      default

    $ openstack --os-cloud rdo-cloud security group rule create \
      --ingress \
      --protocol icmp \
      default

At this point, you are ready to go with your deployment.

Tripleo-Quickstart based deployments
====================================

This is a WIP. Use it like this:

    $ openstack --os-cloud rdo-cloud stack create foo \
    -t templates/traas-oooq.yaml \
    -e templates/traas-oooq-resource-registry.yaml \
    -e templates/example-environments/rdo-cloud-oooq-env.yaml \
    --wait
    $ # trigger your deployment manually or automatically with the placeholder

The main template is:

    templates/traas-oooq.yaml

The example environment is:

    templates/example-environments/rdo-cloud-oooq-env.yaml

Once the nodes are up, the main script that is triggered is:

    scripts/traas-oooq.sh

The script logs to `tripleo-root/traas-oooq.log` in the home directory of the
`centos` user.

> **note**
>
> Changing docker graph driver or remapping its userns will reset
> loaded docker images.

For overcloud nodes to access loaded images from a local registry,
configure the registry for undercloud node, like this:

    # docker pull registry
    # docker run -dit -p 8787:5000 --name registry registry
    # curl -s <ctl_plane_ip>:8787/v2/_catalog | python -mjson.tool

Where the `ctl_plane_ip` comes from the wanted quickstart-extras
variables and normally should be equal to the private undercloud
`local_ip` address.
