source "virtualbox-iso" "arch" {
  # --- Resource Allocation ---
  cpus      = var.cpus
  memory    = var.memory
  disk_size = var.disk_size
  
  # --- OS & Media ---
  guest_os_type = "ArchLinux_64"
  iso_url       = "https://mirrors.kernel.org/archlinux/iso/latest/archlinux-x86_64.iso"
  iso_checksum  = "file:https://mirrors.kernel.org/archlinux/iso/latest/sha256sums.txt"
  headless      = true
  format        = "ova"
  
  # --- Connectivity ---
  ssh_username     = "root"
  ssh_password     = "packer"
  ssh_timeout      = "10m"
  shutdown_command = "systemctl poweroff"
  ssh_host_port_min = 2222
  ssh_host_port_max = 2222

  # --- Hardware Tweaks ---
  vboxmanage = concat(
    var.vbox_tweaks,
    [for pf in var.port_forwards : ["modifyvm", "{{.Name}}", "--natpf1", pf]]
  )

  # --- Boot Sequencing ---
  # Note that these values can be smaller for a headful run
  boot_wait = "30s"
  boot_keygroup_interval = "300ms"
  pause_before_connecting = "1s"
  boot_command = [
    "<enter><wait30>",
    "echo 'root:packer' | chpasswd<enter>",
    "systemctl start sshd<enter>"
  ]
}

build {
  sources = ["source.virtualbox-iso.arch"]

  provisioner "shell" {
    script = "scripts/install.sh"
  }

  post-processor "manifest" {
    output     = "packer-manifest.json"
    strip_path = true
  }
}
