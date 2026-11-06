terraform {
  required_version = ">= 1.8.0"

  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 2.4.0"
    }
  }
}

provider "nutanix" {
  username = var.nutanix_user
  password = var.nutanix_password
  endpoint = var.nutanix_endpoint
  port     = var.nutanix_port
  insecure = var.nutanix_insecure
}

data "nutanix_clusters_v2" "cluster" {
  filter = "name eq '${var.prism_element_cluster_name}'"
}

data "nutanix_subnets_v2" "subnet" {
  filter = "name eq '${var.subnet_name}'"
}

data "nutanix_images_v2" "ubuntu" {
  filter = "name eq '${var.image_name}'"
}

locals {
  cluster_ext_id = data.nutanix_clusters_v2.cluster.cluster_entities[0].ext_id
  subnet_ext_id  = data.nutanix_subnets_v2.subnet.subnets[0].ext_id
  image_ext_id   = data.nutanix_images_v2.ubuntu.images[0].ext_id

  cloud_init_userdata = templatefile("${path.module}/cloud-config.tftpl", {
    hostname   = var.vm_name
    ssh_pubkey = var.ssh_public_key
  })
}

resource "nutanix_virtual_machine_v2" "bootstrap" {
  name        = var.vm_name
  description = "NKP bootstrap node managed with OpenTofu"

  cluster {
    ext_id = local.cluster_ext_id
  }

  num_sockets          = var.num_vcpus
  num_cores_per_socket = 1
  memory_size_bytes    = var.memory_gb * 1024 * 1024 * 1024

  disks {
    disk_address {
      bus_type = "SCSI"
      index    = 0
    }
    backing_info {
      vm_disk {
        disk_size_bytes = var.disk_size_gb * 1024 * 1024 * 1024
        data_source {
          reference {
            image_reference {
              image_ext_id = local.image_ext_id
            }
          }
        }
      }
    }
  }

  nics {
    nic_network_info {
      virtual_ethernet_nic_network_info {
        nic_type  = "NORMAL_NIC"
        vlan_mode = "ACCESS"
        subnet {
          ext_id = local.subnet_ext_id
        }
        ipv4_config {
          should_assign_ip = true
        }
      }
    }
  }

  boot_config {
    legacy_boot {
      boot_order = ["DISK", "CDROM"]
    }
  }

  guest_customization {
    config {
      cloud_init {
        cloud_init_script {
          user_data {
            value = base64encode(local.cloud_init_userdata)
          }
        }
      }
    }
  }

  # cloud-init is consumed on first boot only.
  lifecycle {
    ignore_changes = [guest_customization]
  }
}
