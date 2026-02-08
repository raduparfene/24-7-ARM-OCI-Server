variable "ssh_public_key_path" {
  description = "Path to SSH public key for VM access"
  type        = string
}

variable "instance_shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  type    = number
  default = 4
}

variable "instance_memory_gb" {
  type    = number
  default = 24
}

variable "vnc_password" {
  type    = string
  sensitive = true
}

variable "github_cs_repo" {
  type    = string
  sensitive = true
}
