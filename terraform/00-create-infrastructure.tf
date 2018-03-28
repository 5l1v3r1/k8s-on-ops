### [Network] ###
resource "openstack_compute_keypair_v2" "k8s-keypair" {
  name       = "k8s-keypair"
  public_key = "${file(var.public-key-path)}"
}

resource "openstack_networking_network_v2" "k8s-net" {
  name = "k8s-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "k8s-subnet" {
  name       = "k8s-subnet"
  network_id = "${openstack_networking_network_v2.k8s-net.id}"
  cidr       = "${var.network-cidr}"
  ip_version = 4
  enable_dhcp = "true"
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

resource "openstack_networking_router_v2" "k8s-router" {
  name                = "k8s-router"
  external_network_id = "62954df1-05bb-42e5-9960-ca921cccaeeb"
}

resource "openstack_networking_router_interface_v2" "k8s-interface-1" {
  router_id = "${openstack_networking_router_v2.k8s-router.id}"
  subnet_id = "${openstack_networking_subnet_v2.k8s-subnet.id}"
}


### [ Neutron Security Groups ] ###
resource "openstack_networking_secgroup_v2" "k8s-ssh-provider" {
  name = "k8s-ssh-provider"
}
resource "openstack_networking_secgroup_rule_v2" "k8s-ssh-provider" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "${var.gate_cidr}"
  security_group_id = "${openstack_networking_secgroup_v2.k8s-ssh-provider.id}"
}

resource "openstack_networking_secgroup_v2" "k8s-web-provider" {
  name = "k8s-web-provider"
}
resource "openstack_networking_secgroup_rule_v2" "k8s-web-provider" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.k8s-web-provider.id}"
}
resource "openstack_networking_secgroup_rule_v2" "k8s-web-provider" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.k8s-web-provider.id}"
}

resource "openstack_networking_secgroup_v2" "k8s-cluster-consumer" {
  name = "k8s-cluster-consumer"
}

resource "openstack_networking_secgroup_v2" "k8s-cluster-provider" {
  name = "k8s-cluster-provider"
}
resource "openstack_networking_secgroup_rule_v2" "k8s-cluster-provider" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = "${openstack_networking_secgroup_v2.k8s-cluster-consumer.id}"
  security_group_id = "${openstack_networking_secgroup_v2.k8s-cluster-provider.id}"
}
