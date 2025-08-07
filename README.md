# vsphere-terraform-ubuntu-deploy
vsphere terraform ubuntu automation deploy

This project relies on a pre-configured Ubuntu 24.04 template in vSphere.

    • Installed Terraform.
    • Access to vSphere.
    • Ubuntu 24 Template.
    
    1. Create a Base VM
        ◦ Create a virtual machine from a clean Ubuntu Server 24.04 LTS image.
    2. Install Necessary Tools
        ◦ Install cloud-init and open-vm-tools for proper vSphere integration and automation.
       sudo apt update
       sudo apt install -y cloud-init open-vm-tools
    3. Configure NOPASSWD for Sudo
        ◦ For the provisioner to work, the user needs to be able to execute sudo commands without a password.
       echo "user ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/99-custom-provisioner
    4. Clean Up and Prepare the Template
        ◦ Before converting the VM to a template, clean it up to avoid conflicts with new VMs.
       sudo cloud-init clean --all
       sudo poweroff
    5. Convert to Template
        ◦ In the vSphere client, convert the powered-off virtual machine into a template.

Configuration

    1. Configure project.tfvars
        ◦ Create a project.tfvars file based on the tfvars-template and fill it out. This file contains all project secrets and must be in .gitignore.
    2. Configure provider.tf
        ◦ Specify the address of your vSphere server.
       provider "vsphere" {
         vsphere_server       = "your_vsphere_server_ip"
         user                 = var.vsphere_user
         password             = var.vsphere_password
         allow_unverified_ssl = true
       }

Usage

    1. Initialization
       terraform init
    2. Planning
       terraform plan -var-file="dev_project.tfvars"
    3. Applying
       terraform apply -var-file="dev_project.tfvars"
    4. Destroying
       terraform destroy -var-file="dev_project.tfvars"

Expected Outcome

After a successful terraform apply run, you will have the following infrastructure:

    • A virtual machine will be deployed to the folder specified in your project.tfvars file.
    • The virtual machine's disk will be expanded to 100% of the available space you defined.
    • SSH keys on the virtual machine will be renewed for improved security.
    • A new user will be created with the specified password and added to the sudo group.
