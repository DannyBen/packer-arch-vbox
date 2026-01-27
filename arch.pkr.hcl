source "virtualbox-iso" "arch" {
  # --- Resource Allocation ---
  vm_name   = var.vm_name
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
  # Packer connects via SSH to the live ISO environment to run the installer.
  ssh_username      = "root"
  ssh_password      = "packer"
  ssh_timeout       = "10m"
  shutdown_command  = "systemctl poweroff"
  ssh_host_port_min = 2222
  ssh_host_port_max = 2222

  # --- VirtualBox Config ---
  vboxmanage = [
    # Performance & System Architecture
    # ---------------------------------
    # x2apic: Better interrupt handling for multi-core guests
    # paravirt-provider: "minimal" is often best for Arch on modern VBox
    # rtcuseutc: Ensures guest clock stays in sync with real world
    ["modifyvm", "{{.Name}}", "--x2apic", "on"],
    ["modifyvm", "{{.Name}}", "--paravirt-provider", "minimal"],
    ["modifyvm", "{{.Name}}", "--rtcuseutc", "on"],

    # Graphics & UI Experience
    # ------------------------
    # VMSVGA: The standard driver for Linux guests
    # vram: Better video performance
    # bidirectional: Allows seamless copy-paste and drag-drop
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "vmsvga"],
    ["modifyvm", "{{.Name}}", "--vram", "128"],
    ["modifyvm", "{{.Name}}", "--clipboard-mode", "bidirectional"],
    ["modifyvm", "{{.Name}}", "--draganddrop", "bidirectional"],

    # Networking & Filesystem
    # -----------------------
    # virtio: The "fast lane" for network traffic (virt-io driver)
    # setextradata: The critical fix allowing symlinks on Windows host shares
    ["modifyvm", "{{.Name}}", "--nictype1", "virtio"],
    ["setextradata", "{{.Name}}", "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"],

    # Shared Folder
    # -----------------------
    ["sharedfolder", "add", "{{.Name}}", "--name", "vagrant", "--hostpath", "${abspath(var.shared_folder_hostpath)}"],

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

  post-processor "manifest" {
    output     = "packer-manifest.json"
    strip_path = true
  }
}
