resource "oci_core_instance" "FoggyKitchenBastionServer" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name = "FoggyKitchenBastionServer"
  shape = var.Shape

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.InstanceImageOCID.images[0].id
  }
  
  metadata = {
      ssh_authorized_keys = file(var.public_key_oci)
  }
  
  create_vnic_details {
     subnet_id = oci_core_subnet.FoggyKitchenBastionSubnet.id
     assign_public_ip = true
  }
  
  shape_config {
      memory_in_gbs = 1
      ocpus = 1
  }
}

