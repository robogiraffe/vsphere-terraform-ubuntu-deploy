resource "vsphere_folder" "project_folder" {
  path          = var.project_folder_name
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "ubuntu_static" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.project_folder_name
  firmware         = "efi"
  
  num_cpus = var.vm_cpus
  memory   = var.vm_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id
  
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  
  disk {
    label            = "Hard Disk 1"
    size             = var.vm_disk_size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.vm_name
        domain    = "local"
      }
      
      network_interface {
        ipv4_address = var.vm_ip_address != "" ? var.vm_ip_address : null
        ipv4_netmask = var.vm_ip_address != "" ? var.vm_netmask : null
      }
      
      ipv4_gateway    = var.vm_ip_address != "" ? var.vm_gateway : null
      dns_server_list = var.vm_ip_address != "" ? var.vm_dns_servers : null
    }
  }
  provisioner "remote-exec" {
  inline = [
    #New ssh keys
    "sudo /bin/rm -v /etc/ssh/ssh_host_*",
    "sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure openssh-server",
    "sudo systemctl restart ssh",
    #Expand disk to 100%
    "sudo growpart /dev/sda 3",
    "sudo pvresize /dev/sda3",
    "sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv",
    "sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv",
    "echo 'Disk resize and filesystem extend complete.'",
    #Add user
    "sudo adduser ${var.vm_user} --gecos '${var.vm_user}' --disabled-password",
    "echo '${var.vm_user}:${var.vm_user_password}' | sudo chpasswd",
    "sudo usermod -aG sudo ${var.vm_user}",
    "echo 'User created and added to sudo group.'",
    #Install updates
    "sudo apt update && sudo apt -y upgrade",
    "echo 'Updates installed'"
  ]
    
    connection {
      type        = "ssh"
      user        = var.vm_user_default
      password    = var.vm_password_default
      host        = self.default_ip_address
      timeout     = "5m"
    }
  }
}
