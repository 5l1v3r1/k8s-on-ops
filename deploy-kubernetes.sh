#!/bin/bash
start_dir=$(pwd)

# Source variables
source setup.vars

# Create k8s keypair if not existing
if [ ! -f "$HOME/.ssh/k8s.key" ] || [ ! -f "$HOME/.ssh/k8s.key.pub" ]; then
    ssh-keygen -t rsa -f ~/.ssh/k8s.key -N ''
fi

# Download kubespray
curl -s "https://codeload.github.com/kubernetes-incubator/kubespray/tar.gz/v${KUBESPRAY_VERSION}" | tar -xzv
pip install -r "kubespray-${KUBESPRAY_VERSION}/requirements.txt"

# Deploy infrastructure
source openrc.sh
export TF_VAR_os_tenant_id=$OS_TENANT_ID
export TF_VAR_os_username=$OS_USERNAME
export TF_VAR_os_password=$OS_PASSWORD
export TF_VAR_gate_cidr=$(curl -s api.ipify.org)/32
cd terraform
terraform init
terraform apply

echo ""
read -p "Make sure that nodes has finished initialization (instance logs) and then press Enter to continue"

# Run ansible
cd $start_dir
ansible-playbook -u elastx --private-key "~/.ssh/k8s.key" -i k8s-inventory.yml prepare-nodes.yml
ansible-playbook -u elastx --private-key "~/.ssh/k8s.key" -i k8s-inventory.yml --extra-vars "{ 'helm_enabled': true, 'kubelet_custom_flags': [ '--authentication-token-webhook=true' ] }" -b kubespray-${KUBESPRAY_VERSION}/cluster.yml
