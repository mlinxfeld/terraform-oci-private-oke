resource "oci_core_vcn" "FoggyKitchenVCN" {
  cidr_block     = var.VCN-CIDR
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenVCN"
}

resource "oci_core_drg" "FoggyKitchenDRG" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenDRG"
}

resource "oci_core_drg_attachment" "FoggyKitchenDRGAttachment" {
  drg_id       = oci_core_drg.FoggyKitchenDRG.id
  vcn_id       = oci_core_vcn.FoggyKitchenVCN.id
  display_name = "FoggyKitchenDRGAttachment"
}

resource "oci_core_service_gateway" "FoggyKitchenServiceGateway" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenServiceGateway"
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  services {
    service_id = lookup(data.oci_core_services.FoggyKitchenAllOCIServices.services[0], "id")
  }
}

resource "oci_core_nat_gateway" "FoggyKitchenNATGateway" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenNATGateway"
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
}

resource "oci_core_route_table" "FoggyKitchenRouteTableViaNAT" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenRouteTableViaNAT"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.FoggyKitchenNATGateway.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.FoggyKitchenAllOCIServices.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.FoggyKitchenServiceGateway.id
  }
}

resource "oci_core_internet_gateway" "FoggyKitchenInternetGateway" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenInternetGateway"
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
}

resource "oci_core_route_table" "FoggyKitchenRouteTableViaIGW" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenRouteTableViaIGW"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.FoggyKitchenInternetGateway.id
  }
}

resource "oci_core_security_list" "FoggyKitchenOKESecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenOKESecurityList"
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id

  egress_security_rules {
    protocol    = "All"
    destination = "0.0.0.0/0"
  }

  /* This entry is necesary for DNS resolving (open UDP traffic). */
  ingress_security_rules {
    protocol = "17"
    source   = var.VCN-CIDR
  }
}

resource "oci_core_security_list" "FoggyKitchenPrivateKubernetesAPIEndpointSubnetSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenPrivateKubernetesAPIEndpointSubnetSecurityList"
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id

  # egress_security_rules

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.FoggyKitchenK8SNodePoolSubnet-CIDR
  }

  egress_security_rules {
    protocol         = 1
    destination_type = "CIDR_BLOCK"
    destination      = var.FoggyKitchenK8SNodePoolSubnet-CIDR

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.FoggyKitchenAllOCIServices.services[0], "cidr_block")

    tcp_options {
      min = 443
      max = 443
    }
  }

  # ingress_security_rules

  ingress_security_rules {
    protocol = "6"
    source   = var.FoggyKitchenK8SNodePoolSubnet-CIDR

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.FoggyKitchenK8SNodePoolSubnet-CIDR

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = 1
    source   = var.FoggyKitchenK8SNodePoolSubnet-CIDR

    icmp_options {
      type = 3
      code = 4
    }
  }

}

resource "oci_core_security_list" "FoggyKitchenPrivateKubernetesPrivateWorkerNodesSubnetSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenPrivateKubernetesPrivateWorkerNodesSubnetSecurityList"
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id


  # egress_security_rules

  egress_security_rules {
    protocol         = "All"
    destination_type = "CIDR_BLOCK"
    destination      = var.FoggyKitchenK8SNodePoolSubnet-CIDR
  }

  egress_security_rules {
    protocol    = 1
    destination = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.FoggyKitchenAllOCIServices.services[0], "cidr_block")
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.FoggyKitchenK8SAPIEndPointSubnet-CIDR

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.FoggyKitchenK8SAPIEndPointSubnet-CIDR

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
  }

  # ingress_security_rules

  ingress_security_rules {
    protocol = "All"
    source   = var.FoggyKitchenK8SNodePoolSubnet-CIDR
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.FoggyKitchenK8SAPIEndPointSubnet-CIDR
  }

  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

}

resource "oci_core_subnet" "FoggyKitchenK8SAPIEndPointSubnet" {
  cidr_block     = var.FoggyKitchenK8SAPIEndPointSubnet-CIDR
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenK8SAPIEndPointSubnet"

  security_list_ids          = [oci_core_vcn.FoggyKitchenVCN.default_security_list_id, oci_core_security_list.FoggyKitchenPrivateKubernetesAPIEndpointSubnetSecurityList.id]
  route_table_id             = oci_core_route_table.FoggyKitchenRouteTableViaNAT.id
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "FoggyKitchenK8SLBSubnet" {
  cidr_block     = var.FoggyKitchenK8SLBSubnet-CIDR
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenK8SLBSubnet"

  security_list_ids          = [oci_core_vcn.FoggyKitchenVCN.default_security_list_id]
  route_table_id             = oci_core_route_table.FoggyKitchenRouteTableViaNAT.id
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "FoggyKitchenK8SNodePoolSubnet" {
  cidr_block     = var.FoggyKitchenK8SNodePoolSubnet-CIDR
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenK8SNodePoolSubnet"

  security_list_ids          = [oci_core_vcn.FoggyKitchenVCN.default_security_list_id, oci_core_security_list.FoggyKitchenPrivateKubernetesPrivateWorkerNodesSubnetSecurityList.id]
  route_table_id             = oci_core_route_table.FoggyKitchenRouteTableViaNAT.id
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "FoggyKitchenBastionSubnet" {
  cidr_block     = var.FoggyKitchenBastionSubnet-CIDR
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenBastionSubnet"

  security_list_ids = [oci_core_vcn.FoggyKitchenVCN.default_security_list_id, oci_core_security_list.FoggyKitchenOKESecurityList.id]
  route_table_id    = oci_core_route_table.FoggyKitchenRouteTableViaIGW.id
}
