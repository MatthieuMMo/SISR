resource "proxmox_vm_qemu" "training" {
  count       = 3
  vmid        = var.vmids[count.index]
  name        = "kubernetes-${count.index + 1}"
  description = "VM Kubernetes ${count.index + 1}"

  target_node = "proxmox"

  cpu {
    type      = "host"
    cores     = 1
  }         
  memory      = 1024 

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
    bridge    = "vmbr20"
  }

  ipconfig0   = "ip=${var.ips[count.index]},gw=192.168.20.254"
}
