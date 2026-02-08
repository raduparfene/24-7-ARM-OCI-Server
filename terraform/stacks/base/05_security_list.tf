resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "security-list-public"

  # OUTBOUND: allow everything
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  # INBOUND: SSH (22) - just myself
  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.my_public_ip

    tcp_options {
      min = 22
      max = 22
    }
  }

  # INBOUND: ICMP ping
  ingress_security_rules {
    protocol = "1" # ICMP
    source   = "0.0.0.0/0"

    icmp_options {
      type = 8
    }
  }

  # FastDL (Nginx) – HTTP 80
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS - 443
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }

  # INBOUND: UDP for CS 1.6
  ingress_security_rules {
    protocol = "17" # UDP
    source   = "0.0.0.0/0"

    udp_options {
      min = 27015
      max = 27020
    }
  }

  # INBOUND: TCP for CS 1.6
  ingress_security_rules {
    protocol = "6"  # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 27015
      max = 27020
    }
  }

  # INBOUND: TCP for Minecraft
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 25565
      max = 25565
    }
  }
}
