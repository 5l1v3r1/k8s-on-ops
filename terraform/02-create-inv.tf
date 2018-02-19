resource "null_resource" "ansible-provision" {

  depends_on = ["openstack_compute_floatingip_associate_v2.k8s-ip-associate"]

  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s-instance.*.name, openstack_compute_floatingip_associate_v2.k8s-ip-associate.*.floating_ip))}\" >> ../k8s-inventory.yml"
  }

  ##Create ETCD Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[etcd]\" >> ../k8s-inventory.yml"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",openstack_compute_instance_v2.k8s-instance.*.name)}\" >> ../k8s-inventory.yml"
  }

  ##Create Masters Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[kube-master]\" >> ../k8s-inventory.yml"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",openstack_compute_instance_v2.k8s-instance.*.name)}\" >> ../k8s-inventory.yml"
  }

  ##Create Nodes Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[kube-node]\" >> ../k8s-inventory.yml"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",openstack_compute_instance_v2.k8s-instance.*.name)}\" >> ../k8s-inventory.yml"
  }

  provisioner "local-exec" {
    command =  "echo \"\n[k8s-cluster:children]\nkube-node\nkube-master\" >> ../k8s-inventory.yml"
  }
}
