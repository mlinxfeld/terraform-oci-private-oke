data "template_file" "ocicli_config" {
  template = file("templates/ocicli_config")

  vars = {
    user_ocid    = var.user_ocid
    fingerprint  = var.fingerprint
    tenancy_ocid = var.tenancy_ocid
    region       = var.region
  }
}

resource "null_resource" "FoggyKitchenBastionServer_ConfigMgmt" {
  depends_on = [oci_core_instance.FoggyKitchenBastionServer]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = ["echo '== 1. Install kubectl'",
      "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"",
      "chmod +x /home/opc/kubectl",
      "/home/opc/kubectl version",

      "echo '== 2. Install OCI CLI'",
      "sudo -u root yum install -y python36-oci-cli",
      "rm -rf /home/opc/.oci",
      "mkdir /home/opc/.oci/",
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }

    content     = tls_private_key.public_private_key_pair.private_key_pem
    destination = "/home/opc/.oci/oci_api_key.pem"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }

    content     = data.template_file.ocicli_config.rendered
    destination = "/home/opc/.oci/config"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = ["echo '== 3. Setup OCI CLI'",
      "chmod 600 /home/opc/.oci/oci_api_key.pem"
    ]
  }
}
