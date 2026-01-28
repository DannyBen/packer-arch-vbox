# Arch Linux Packer Build (VirtualBox)

This folder builds a minimal Arch Linux VirtualBox OVA using Packer.

The build boots the official Arch ISO, installs a base system, and configures a
virtual machine that aims to provide an experience similar to Vagrant.

## What's in the Box

- Arch Linux headless
- Root user (`root:root`)
- Vagrant user (`vagrant:vagrant`)
- VirtualBox Guest Utils
- Shared folder (guest: /vagrant)
- Forwarded development ports
- Optimizations for Linux guests on VirtualBox Windows hosts

## Requirements

- [Packer](https://developer.hashicorp.com/packer/install) (HCL2)
- VirtualBox

## Building the OVA

```bash
# Download needed plugins
packer init .

# Build
packer build -force .

# or, build with logging using the provided build.cmd (assuming packer.exe
# is in your PATH)
build
```

## Installing the OVA

1. Double click the OVA (or select File > Import Appliance from VirtualBox).
2. Change the machine name.
3. Change the shared folder host directory (keep the name `vagrant`).
4. Boot the VM.
5. Log in with `ssh vagrant@localhost -p 2222` or use the VM console with
   `root:root` or `vagrant:vagrant`.

## Outputs

- OVA artifact in `output-arch/`
- Build manifest in `packer-manifest.json`
- Packer log in `packer.log` (when using `build.cmd`)

## Variables

Defaults are in `variables.pkr.hcl`. Override with `-var` or a `.pkrvars.hcl` file.

- `shared_folder_hostpath` (string): host path to share with the VM
- `cpus` (number): vCPU count
- `memory` (number): RAM in MB
- `disk_size` (number): disk size in MB

Example:

```bash
packer build -var "cpus=2" -var "memory=4096" .
```

## Notes

- The installer wipes `/dev/sda`.
- NAT port forwarding includes SSH on host port `2222` by default.
- The build is headless; set `headless = false` in `arch.pkr.hcl` if you want to watch the VM boot.
- Optional helpers are in `extra/` (`up.bat`, `halt.bat`). These assume a VM named `arch-linux` and use VBoxManage from the default install path; `up.bat` elevates to admin.

## Releases

Tags use CalVer. Example: `2026.01.28` (or `2026.01.28.1` for multiple releases in a day).
When a tag is pushed, GitHub Actions builds the OVA and attaches it to the release.
The workflow expects a self-hosted runner with VirtualBox installed.

## Files

- `arch.pkr.hcl`: Packer template
- `variables.pkr.hcl`: Variable defaults and descriptions
- `scripts/install.sh`: Arch install and configuration
- `build.cmd`: Windows helper script
