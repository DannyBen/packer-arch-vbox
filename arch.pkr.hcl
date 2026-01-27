packer {
  required_plugins {
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

source "virtualbox-iso" "arch" {
  # Use the variables
  cpus                 = var.cpus
  memory               = var.memory
  disk_size            = var.disk_size
  
  guest_os_type        = "ArchLinux_64"
  iso_url              = "https://mirrors.kernel.org/archlinux/iso/latest/archlinux-x86_64.iso"
  iso_checksum         = "file:https://mirrors.kernel.org/archlinux/iso/latest/sha256sums.txt"
  headless             = false
  http_directory       = "scripts"

  ssh_host_port_min    = 2222
  ssh_host_port_max    = 2222
  ssh_wait_timeout     = "1000s" # Give the VM plenty of time to boot

  vboxmanage = concat(
    var.vbox_tweaks,
    # This loop turns your port_forwards list into VBoxManage commands
    [for pf in var.port_forwards : ["modifyvm", "{{.Name}}", "--natpf1", pf]]
  )

  # Boot & SSH
  boot_command = [
    "<enter><wait20>",
    "echo 'root:packer' | chpasswd<enter>",
    "systemctl start sshd<enter>"
  ]

  ssh_username = "root"
  ssh_password = "packer"
  shutdown_command = "systemctl poweroff"
  ssh_timeout          = "30m"
}

build {
  sources = ["source.virtualbox-iso.arch"]
  provisioner "shell" {
    script = "scripts/install.sh"
    # This ensures Packer sees the output in your terminal
  }
}
