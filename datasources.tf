data "oci_containerengine_cluster_option" "FoggyKitchenOKEClusterOption" {
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "FoggyKitchenOKEClusterNodePoolOption" {
  node_pool_option_id = "all"
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "key_script" {
  template = file("./scripts/sshkey.tpl")
  vars = {
    ssh_public_key = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.key_script.rendered
  }
}


data "oci_core_vnic_attachments" "FoggyKitchenBastionServer_VNIC1_attach" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  instance_id         = oci_core_instance.FoggyKitchenBastionServer.id
}

data "oci_core_vnic" "FoggyKitchenBastionServer_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.FoggyKitchenBastionServer_VNIC1_attach.vnic_attachments.0.vnic_id
}

# Get the latest Oracle Linux image
data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.Shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

data "oci_core_services" "FoggyKitchenAllOCIServices" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

