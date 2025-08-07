terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = "192.168.122.66"
  allow_unverified_ssl = true
}
