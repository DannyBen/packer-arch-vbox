# Arch Linux Packer Build (VirtualBox)

![repocard](repocard.svg)

This folder builds a minimal Arch Linux VirtualBox OVA using Packer.

The build boots the official Arch ISO, installs a base system, and configures a
virtual machine that aims to provide a familiar experience to Vagrant users.

This image is designed **FOR DEVELOPMENT ONLY**.

## What's in the Box

- Arch Linux headless
- Root user (`root:root`)
- Vagrant user (`vagrant:vagrant`)
- VirtualBox Guest Utils
- Shared folder (guest: /vagrant)
- Forwarded development ports
- Optimizations for Linux guests on VirtualBox Windows hosts

## How to Use

You can either build the box yourself, or use the pre-built OVA from the
[releases page][releases].

## Build Requirements

- [Packer](https://developer.hashicorp.com/packer/install)
- [VirtualBox](https://www.virtualbox.org/)

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

### Build notes

- Do not run this in subst dirs, only native dirs.
- Power off any other virtual machine when building.

## Installing the OVA

1. Double click the OVA (or select File > Import Appliance from VirtualBox).
2. Change the machine name.
3. Change the shared folder host directory (keep the name `vagrant`).
4. Boot the VM.
5. Log in with `ssh vagrant@localhost -p 2222` or use the VM console with
   `root:root` or `vagrant:vagrant`.

## Outputs

- OVA artifact in `output-arch/`
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

## Optimization Notes

### What You Need To Do

- Disable Hyper-V (run in **Administrator CMD**, then do a full shutdown/start):
  ```bat
  bcdedit /set hypervisorlaunchtype off
  dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /NoRestart
  ```
- Start VirtualBox as Administrator (right-click shortcut -> **Run as administrator**).
- If symlinks still fail, open `secpol.msc` -> Local Policies -> User Rights Assignment -> Create symbolic links, add your user, then sign out/sign in.

### What Packer Already Does (And Why)

- Enables `VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant=1` so symlink creation can work on Windows-hosted shared folders.
- Sets `--paravirt-provider kvm`, `--x2apic on`, and `--nictype1 virtio` to improve Linux guest performance and interrupt/network behavior.

### Verification Checklist

- In VM status/details, execution engine should show `VT-x/AMD-V` (not `Native API`).
- VM window should show the blue `V` icon (not the green turtle icon).
- Inside the guest, creating a symlink under `/vagrant` should succeed.

## Releases

Tags use CalVer. Example: `26.01.28` (or `26.01.28.1` for multiple releases in a day).

You can download the built OVA from the [releases page][releases].

## Files

- `arch.pkr.hcl`: Packer template
- `variables.pkr.hcl`: Variable defaults and descriptions
- `scripts/install.sh`: Arch install and configuration
- `build.cmd`: Windows helper script


[releases]: https://github.com/DannyBen/packer-arch-vbox/releases
