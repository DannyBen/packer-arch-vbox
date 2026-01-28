source "virtualbox-iso" "arch" {
  # --- Resource Allocation ---
  cpus      = var.cpus
  memory    = var.memory
  disk_size = var.disk_size

  # --- OS & Media ---
  guest_os_type  = "ArchLinux_64"
  iso_url        = "https://mirrors.kernel.org/archlinux/iso/latest/archlinux-x86_64.iso"
  iso_checksum   = "file:https://mirrors.kernel.org/archlinux/iso/latest/sha256sums.txt"
  headless       = true
  format         = "ova"

  # --- Connectivity ---
  # Packer connects via SSH to the live ISO environment to run the installer.
  ssh_username      = "root"
  ssh_password      = "packer"
  ssh_timeout       = "10m"
  shutdown_command  = "systemctl poweroff"
  ssh_host_port_min = 2222
  ssh_host_port_max = 2222

  # --- VirtualBox Config ---
  hard_drive_interface = "sata"
  vboxmanage = [
    # Performance & System Architecture
    # ---------------------------------
    # x2apic: Better interrupt handling for multi-core guests
    # paravirt-provider: "kvm" is often best for Arch on modern VBox
    # rtcuseutc: Ensures guest clock stays in sync with real world
    ["modifyvm", "{{.Name}}", "--x2apic", "on"],
    ["modifyvm", "{{.Name}}", "--paravirt-provider", "kvm"],
    ["modifyvm", "{{.Name}}", "--rtcuseutc", "on"],

    # USB
    # ------------------------
    ["modifyvm", "{{.Name}}", "--usb", "on", "--usbehci", "on"],

    # Graphics & UI Experience
    # ------------------------
    # VMSVGA: The standard driver for Linux guests
    # vram: Better video performance
    # usbtablet: Better pointing device
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "vmsvga"],
    ["modifyvm", "{{.Name}}", "--vram", "128"],
    ["modifyvm", "{{.Name}}", "--mouse", "usbtablet"],

    # Networking & Filesystem
    # -----------------------
    # virtio: The "fast lane" for network traffic (virt-io driver)
    ["modifyvm", "{{.Name}}", "--nictype1", "virtio"],

    # Shared Folder
    # -----------------------
    ["sharedfolder", "add", "{{.Name}}", "--name", "vagrant", "--hostpath", "${abspath(var.shared_folder_hostpath)}"],

    # Hard Disk
    # setextradata: The critical fix allowing symlinks on Windows host shares
    # Note that VirtualBox needs to start as admin for this to work              
    # ------------------------
    ["storagectl", "{{.Name}}", "--name", "SATA Controller", "--hostiocache", "on"],
    ["storageattach", "{{.Name}}", "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"],
    ["setextradata", "{{.Name}}", "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"],

    # Port Forwarding
    # Format: name, protocol, hostip, hostport, guestip, guestport
    ["modifyvm", "{{.Name}}", "--natpf1", "SSH,tcp,,2222,,22"],
    ["modifyvm", "{{.Name}}", "--natpf1", "HTTP,tcp,,80,,80"],
    ["modifyvm", "{{.Name}}", "--natpf1", "HTTPS,tcp,,443,,443"],
    ["modifyvm", "{{.Name}}", "--natpf1", "Web3000,tcp,,3000,,3000"],
    ["modifyvm", "{{.Name}}", "--natpf1", "Web4000,tcp,,4000,,4000"],
    ["modifyvm", "{{.Name}}", "--natpf1", "Web5000,tcp,,5000,,5000"],
    ["modifyvm", "{{.Name}}", "--natpf1", "Web8080,tcp,,8080,,8080"]
  ]

  # --- Boot Sequencing ---
  # This waits for the Arch ISO prompt, sets a temporary root password,
  # and starts SSH so Packer can connect.
  boot_wait              = "30s"
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
}
