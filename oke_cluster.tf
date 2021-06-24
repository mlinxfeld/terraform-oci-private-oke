
resource "oci_containerengine_cluster" "FoggyKitchenOKECluster" {
  #depends_on = [oci_identity_policy.FoggyKitchenOKEPolicy1]
  compartment_id     = oci_identity_compartment.FoggyKitchenCompartment.id
  kubernetes_version = var.kubernetes_version
  name               = var.ClusterName
  vcn_id             = oci_core_vcn.FoggyKitchenVCN.id

  endpoint_config {
    is_public_ip_enabled = false
    subnet_id            = oci_core_subnet.FoggyKitchenK8SAPIEndPointSubnet.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.FoggyKitchenK8SLBSubnet.id]

    add_ons {
      is_kubernetes_dashboard_enabled = true
      is_tiller_enabled               = true
    }

    kubernetes_network_config {
      pods_cidr     = var.cluster_options_kubernetes_network_config_pods_cidr
      services_cidr = var.cluster_options_kubernetes_network_config_services_cidr
    }
  }
}

locals {
  all_sources         = data.oci_containerengine_node_pool_option.FoggyKitchenOKEClusterNodePoolOption.sources
  oracle_linux_images = [for source in local.all_sources : source.image_id if length(regexall("Oracle-Linux-[0-9]*.[0-9]*-20[0-9]*", source.source_name)) > 0]
}

resource "oci_containerengine_node_pool" "FoggyKitchenOKENodePool" {
  #depends_on = [oci_identity_policy.FoggyKitchenOKEPolicy1]
  cluster_id         = oci_containerengine_cluster.FoggyKitchenOKECluster.id
  compartment_id     = oci_identity_compartment.FoggyKitchenCompartment.id
  kubernetes_version = var.kubernetes_version
  name               = "FoggyKitchenOKENodePool"
  node_shape         = var.Shape

  node_source_details {
    image_id    = data.oci_core_images.InstanceImageOCID.images[0].id
    source_type = "IMAGE"
  }

  dynamic "node_shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.Flex_shape_memory
      ocpus         = var.Flex_shape_ocpus
    }
  }

  node_config_details {
    size = var.node_pool_size

    placement_configs {
      availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availablity_domain_name
      subnet_id           = oci_core_subnet.FoggyKitchenK8SNodePoolSubnet.id
    }
  }

  initial_node_labels {
    key   = "key"
    value = "value"
  }

  ssh_public_key = tls_private_key.public_private_key_pair.public_key_openssh
}

