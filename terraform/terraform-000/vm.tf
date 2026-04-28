resource "proxmox_vm_qemu" "training" {
  count       = 1
  vmid        = 1013
  name        = "1013-VPN"
  description = "vm dediee a wireguard"

  target_node = "proxmox"

  cpu {
    type      = "host"
    cores     = 1
  }         
  memory      = 512  

  os_type     = "cloudinit"

  ciuser      = "dinoshop-admin"
  sshkeys     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKB0KTF1dRKqeAsGHPpHcidwUYnBlTZ9W0N/yv/BjJk9 persillade@persillade-Aspire-A315-44P"
  
  full_clone  = false
  clone       = "debian13-cloudinit"
  
  serial {
    id        = 0
  }

  scsihw      = "virtio-scsi-single"
  
  disks {
    ide {
      ide3 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = 30 
          format  = "qcow2"
          
        }
      }
    }
  }

  network {
    id        = 0 
    model     = "virtio"
    bridge    = "vmbr10"
  }

  ipconfig0   = "ip=192.168.10.253/24,gw=192.168.10.254"
}
