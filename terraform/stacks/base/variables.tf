variable "compartment_ocid" {
  description = "Compartment OCID where resources will be created"
  type        = string
}

variable "my_public_ip" {
  description = "My public IP for SSH access (format: x.x.x.x/32)"
  type        = string
}

variable "reserved_public_ip_ocid" {
  description = "OCI OCID for the Public Static IP"
  type = string
}
