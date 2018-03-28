resource "openstack_compute_servergroup_v2" "k8s-srvgrp" {
  name = "k8s-srvgrp"
  policies = ["anti-affinity"]
}

resource "openstack_networking_floatingip_v2" "k8s-ip" {
  count = "${var.node-count}"
  pool = "ext-net-01"
}

resource "openstack_compute_instance_v2" "k8s-instance" {
  count = "${var.node-count}"
  name = "k8s-srv${count.index+1}"
  image_name = "ubuntu-16.04-server-latest"
  flavor_name = "m1.xlarge"
  key_pair = "${openstack_compute_keypair_v2.k8s-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.k8s-ssh-provider.name}","${openstack_networking_secgroup_v2.k8s-web-provider.name}","${openstack_networking_secgroup_v2.k8s-cluster-provider.name}","${openstack_networking_secgroup_v2.k8s-cluster-consumer.name}"]
  user_data = "${file(var.user-data-path)}"
  network {
    uuid = "${openstack_networking_network_v2.k8s-net.id}"
  }
  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.k8s-srvgrp.id}"
  }
}

resource "openstack_compute_floatingip_associate_v2" "k8s-ip-associate" {
  count = "${var.node-count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.k8s-ip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.k8s-instance.*.id, count.index)}"
  provisioner "remote-exec" {
    inline = ["uname -a"]
    connection {
      host = "${element(openstack_networking_floatingip_v2.k8s-ip.*.address, count.index)}"
      user = "elastx"
      private_key = "${file(var.private-key-path)}"
      timeout = "20m"
    }
  }
}
