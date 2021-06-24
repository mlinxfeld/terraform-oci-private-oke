resource "oci_core_instance" "FoggyKitchenBastionServer" {
  availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenBastionServer"
  shape               = var.BastionShape

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.InstanceImageOCID.images[0].id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.FoggyKitchenBastionSubnet.id
    assign_public_ip = true
  }

  dynamic "shape_config" {
    for_each = local.is_flexible_bastion_shape ? [1] : []
    content {
      memory_in_gbs = var.Bastion_flex_shape_memory
      ocpus         = var.Bastion_flex_shape_ocpus
    }
  }

}

