variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "private_key_oci" {}
variable "public_key_oci" {}

variable "VCN-CIDR" {
  default = "10.0.0.0/16"
}

variable "cluster_options_kubernetes_network_config_pods_cidr" {
  default = "10.1.0.0/16"
}

variable "cluster_options_kubernetes_network_config_services_cidr" {
  default = "10.2.0.0/16"
}

variable "FoggyKitchenClusterSubnet-CIDR" {
  default = "10.0.1.0/24"
}

variable "FoggyKitchenBastionSubnet-CIDR" {
  default = "10.0.2.0/24"
}

variable "FoggyKitchenNodePoolSubnet-CIDR" {
  default = "10.0.3.0/24"
}

variable "node_pool_quantity_per_subnet" {
  default = 2
}

variable "kubernetes_version" {
#  default = "v1.14.8"
   default = "v1.19.7"
}

variable "node_pool_size" {
  default = 3
}

variable "instance_os" {
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  default     = "7.9"
}

variable "Shape" {
 default = "VM.Standard.E3.Flex"
}

variable "ClusterName" {
  default = "FoggyKitchenOKECluster"
}


variable "oci_service_gateway" {
  type = map
  default = {
    ap-mumbai-1 = "all-bom-services-in-oracle-services-network"
    ap-seoul-1 = "all-icn-services-in-oracle-services-network"
    ap-sydney-1 = "all-syd-services-in-oracle-services-network"
    ap-tokyo-1 = "all-nrt-services-in-oracle-serviecs-network"
    ca-toronto-1 = "all-yyz-services-in-oracle-services-network"
    eu-frankfurt-1 = "all-fra-services-in-oracle-services-network"
    eu-zurich-1 = "all-zrh-services-in-oracle-services-network"
    sa-saopaulo-1 = "all-gru-services-in-oracle-services-network"
    uk-london-1 = "all-lhr-services-in-oracle-services-network"
    us-ashburn-1 = "all-iad-services-in-oracle-services-network"
    us-langley-1 = "all-lfi-services-in-oracle-services-network"
    us-luke-1 = "all-luf-services-in-oracle-services-network"
    us-phoenix-1 = "all-phx-services-in-oracle-services-network"
  }
}

