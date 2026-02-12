# find the network interface
data "oci_core_vnic_attachments" "instance_vnics" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.vm.id
}

# find the private ip
data "oci_core_private_ips" "instance_private_ips" {
  vnic_id = data.oci_core_vnic_attachments.instance_vnics.vnic_attachments[0].vnic_id
}

data "oci_core_public_ip" "reserved" {
  id = var.reserved_public_ip_ocid
}

data "oci_core_vnic_attachments" "va" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.vm.id
}

data "oci_core_vnic" "primary" {
  vnic_id = data.oci_core_vnic_attachments.va.vnic_attachments[0].vnic_id
}

locals {
  primary_private_ip_id = one([
    for p in data.oci_core_private_ips.instance_private_ips.private_ips :
    p.id if p.is_primary
  ])
}

# associate the ip with the instance
resource "oci_core_public_ip" "reserved" {
  compartment_id = var.compartment_ocid
  lifetime = "RESERVED"

  private_ip_id = local.primary_private_ip_id
  lifecycle {
    prevent_destroy = true
  }
}