# Arch Linux Packer Build (VirtualBox)

This folder builds a minimal Arch Linux VirtualBox OVA using Packer. The build boots the official Arch ISO, installs a base system, and configures a vagrant user plus VirtualBox guest utilities.

## Requirements

- Packer (HCL2)
- VirtualBox
- Internet access to download the Arch ISO

## Quick Start

```bash
packer init .
packer build -force .
```

On Windows you can use:

```cmd
build.cmd
```

## Outputs

- OVA artifact in `output-arch/`
- Build manifest in `packer-manifest.json`
- Packer log in `packer.log` (when using `build.cmd`)

## Variables

Defaults are in `variables.pkr.hcl`. Override with `-var` or a `.pkrvars.hcl` file.

- `cpus` (number): vCPU count
- `memory` (number): RAM in MB
- `disk_size` (number): disk size in MB
- `port_forwards` (list(string)): VirtualBox NAT port forwards
- `vbox_tweaks` (list(list(string))): extra `vboxmanage` settings

Example:

```bash
packer build -var "cpus=2" -var "memory=4096" .
```

## Credentials

- Live ISO SSH: `root` / `packer`
- Installed system:
  - `root` / `root`
  - `vagrant` / `vagrant`

Change these after first boot if you plan to use the image beyond local testing.

## Notes

- The installer wipes `/dev/sda`.
- NAT port forwarding includes SSH on host port `2222` by default.
- The build is headless; set `headless = false` in `arch.pkr.hcl` if you want to watch the VM boot.

## Files

- `arch.pkr.hcl`: Packer template
- `variables.pkr.hcl`: Variable defaults and descriptions
- `scripts/install.sh`: Arch install and configuration
- `build.cmd`: Windows helper script
