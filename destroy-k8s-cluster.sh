#!/bin/bash
start_dir=$(pwd)

# Destroy infrastructure
source openrc.sh
export TF_VAR_os_tenant_id=$OS_TENANT_ID
export TF_VAR_os_username=$OS_USERNAME
export TF_VAR_os_password=$OS_PASSWORD
export TF_VAR_gate_cidr=$(curl -s api.ipify.org)/32
cd terraform
terraform destroy

cd $start_dir
rm k8s-inventory.yml

echo "Infrastructure destroyed!"
