variable "cpus" {
  type    = number
  default = 4
}

variable "memory" {
  type    = number
  default = 8192
}

variable "disk_size" {
  type    = number
  default = 40000
}

variable "port_forwards" {
  type = list(string)
  default = [
    "HTTP,tcp,,80,,80",
    "HTTPS,tcp,,443,,443",
    "SSH,tcp,,2222,,22",
    "Web 3000,tcp,,3000,,3000",
    "Web 8080,tcp,,8080,,8080"
  ]
}

# Store generic hardware tweaks
variable "vbox_tweaks" {
  type = list(list(string))
  default = [
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
    ["setextradata", "{{.Name}}", "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
  ]
}
