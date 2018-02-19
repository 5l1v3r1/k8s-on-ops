# These variables are received through ENV variables created
# by terraform-openrc.sh. Run that first.

variable "gate_cidr" {}
variable "os_password" {}
variable "os_username" {}
variable "os_tenant_id" {}
variable "public-key-path" {
  default = "~/.ssh/k8s.key.pub"
}
variable "private-key-path" {
  default = "~/.ssh/k8s.key"
}

variable "node-count" {
  default = 3
}
variable "network-cidr" {
  default = "10.10.10.0/24"
}
variable "user-data-path" {
  default = "cloud-init.conf"
}

### [Openstack] ###
provider "openstack" {
  user_name = "${var.os_username}"
  tenant_id = "${var.os_tenant_id}"
  password = "${var.os_password}"
}

### [Data Backend] ###
terraform {
  backend "swift" {
    container = "terraform/k8s"
  }
}
