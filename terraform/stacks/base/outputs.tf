output "vcn_id" {
  value = oci_core_vcn.main.id
}

output "public_ip" {
  value = oci_core_instance.vm.public_ip
}
