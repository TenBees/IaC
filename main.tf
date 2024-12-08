terraform {
  required_providers {
    proxmox = {
      source = "Terraform-for-Proxmox/proxmox"
      version = "0.0.1"
    }
  }
}
variable "pm_password" {
  description = "The Proxmox user password"
  type        = string
  sensitive   = true
}
variable "pm_user" {
  description = "The Proxmox user"
  type        = string
  sensitive   = true
}
provider "proxmox" {
  pm_api_url      = "https://prox.ten-bees.com/api2/json"
  pm_user         = ${{ secrets.PM_USER }}
  pm_password     = ${{ secrets.PM_PASSWORD }}
  pm_tls_insecure = true  # Not recommended for production
}

resource "proxmox_vm_qemu" "terraform-vm" {
  count       = "2"
  name        = "terraform-vm-${count.index}"
  target_node = "pve"
  clone         = "ubuntu-desktop"
  vmid = 113 + count.index
  

  disk {
    size           = "32G"
    storage        = "local-lvm"
    type           = "scsi"
  }

  lifecycle {
  ignore_changes = [disk]
}

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  ciuser = "tenbee"
  cipassword = "66466"
  cores   = 2
  sockets = 1
  memory  = 2048  # Memory in MB
  ipconfig0 = "ip=192.168.1.${100 + count.index}/24,gw=192.168.1.1"
}
