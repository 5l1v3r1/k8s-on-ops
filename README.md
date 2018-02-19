# k8s-on-ops 
(Almost) 1 button click install for deploying K8s cluster on Openstack.

## Prerequisites
- An OpenStack tenant and account
- Python 2.7 and python-pip installed
- Terraform installed, tested with v0.11.2

## Installing
1. Download your openrc file at `https://ops.elastx.net/project/access_and_security/api_access/openrc/` and save it as `openrc.sh` in same directory as this README.

2. Run `bash deploy-kubernetes.sh`.

3. Kubespray will be downloaded and requirements installed.

4. Script will ask for your openstack username and password, once provided Terraform will initialize and plan infrastructure in OpenStack. If it looks OK accept deployment with `yes[ENTER]`.

5. Once infrastructure is up script will pause as cloud-init will patch and install ansible on the newly created VMs. This takes a couple of minutes (you can confifrm by checking instance logs in Horizon if it's done or not). Press Enter to continue with installing K8s

6. Kubespray will run and install K8s with Calico as CNI and Helm. All VMs are participating in etcd cluster and K8s master and node.

## Upgrading
1. Check if Docker version has changed in newer release of Kubespray. If so update apt pin version in `prepare-nodes.yml` 

2. Update Kubespray version in `setup.vars`

3. Run `bash upgrade-k8s.sh`

## Destroying
1. Run `bash destroy-k8s-cluster.sh`
