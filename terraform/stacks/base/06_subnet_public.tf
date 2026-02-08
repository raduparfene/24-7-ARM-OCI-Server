resource "oci_core_subnet" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id

  cidr_block   = "10.0.1.0/24"
  display_name = "subnet-public"
  dns_label    = "pub1"

  route_table_id = oci_core_route_table.rt_public.id

  prohibit_public_ip_on_vnic = false # allow public IP

  security_list_ids = [
    oci_core_security_list.public.id
  ]
}
