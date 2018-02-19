#!/bin/bash

# Source variables
source setup.vars

# Download kubespray
curl -s "https://codeload.github.com/kubernetes-incubator/kubespray/tar.gz/v${KUBESPRAY_VERSION}" | tar -xzv
pip install -r "kubespray-${KUBESPRAY_VERSION}/requirements.txt"

# Run ansible
ansible-playbook -u elastx --private-key "~/.ssh/k8s.key" -i k8s-inventory.yml prepare-nodes.yml
ansible-playbook -u elastx --private-key "~/.ssh/k8s.key" -i k8s-inventory.yml --extra-vars "{ 'helm_enabled': true, 'kubelet_custom_flags': [ '--authentication-token-webhook=true' ] }" -b kubespray-${KUBESPRAY_VERSION}/cluster.yml
