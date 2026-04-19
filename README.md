# Arch Linux Packer Build (VirtualBox)

![repocard](https://repocard.dannyben.com/svg/arch-build.svg)

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
2. In the Import dialog: Change the machine name.
3. In the Settings dialog: Change the shared folder host directory.
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

- Disable Windows Hypervisor for VirtualBox Performance ([instructions](#how-to-disable-windows-hypervisor))
- Always run the virtual machine as admin. You can use the [up.bat](up.bat) file, and create a shortcut for it with "Run As Administrator" enabled.
- Ensure you can create symlinks in the shared folder, if not see [possible fixes](#hot-to-fix-symlinks)

### What Packer Already Does (And Why)

- Enables `VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant=1` so symlink creation can work on Windows-hosted shared folders.
- Sets `--paravirt-provider kvm`, `--x2apic on`, and `--nictype1 virtio` to improve Linux guest performance and interrupt/network behavior.
- Enables VirtualBox audio with `Intel HD Audio` and adds `vagrant` to the `audio` group.

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

---

## How to disable Windows Hypervisor

### 1) Disable hypervisor at boot (required)

Run in **Administrator Command Prompt**:

```bat
bcdedit /set hypervisorlaunchtype off
```

### 2) Disable Hyper-V (if present)

```bat
dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /NoRestart
```

If you get:
```
Feature name ... is unknown
```
this is safe to ignore (your Windows edition does not include Hyper-V).

### 3) Disable other hypervisor-triggering features (critical)

Check current state:

```bat
dism /online /get-features /format:table | findstr /i "VirtualMachinePlatform HypervisorPlatform"
```

If any of these are **Enabled**, disable them:

```bat
dism /online /disable-feature /featurename:VirtualMachinePlatform /NoRestart
dism /online /disable-feature /featurename:HypervisorPlatform /NoRestart
```

### 4) Reboot

A full reboot is required for changes to take effect.

### 5) Verify hypervisor is disabled

After reboot:

```bat
systeminfo | find "Hypervisor"
```

Expected result: No output

If you still see:
```
A hypervisor has been detected...
```
then a Windows security feature is still enabling it.

### 6) If still enabled (only if needed)

Open: **Windows Security** → **Device Security** → **Core Isolation**

Turn **Memory Integrity OFF**, then reboot again.

### 7) Run VirtualBox

Start VirtualBox as Administrator.

## How to fix symlinks

Try creating a symlink in the shared folder:

```bash
cd /vagrant
ln -s ~ testlink
```

If it fails, follow these steps:

1. Terminate the machine and shut down VirtualBox
2. Open terminal as administrator
3. Run
   ```
   "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" setextradata "arch-linux" VBoxInternal2/SharedFoldersEnableSymlinksCreate/SHARE_NAME 1
   ```
4. Start the machine **as administrator**.


[releases]: https://github.com/DannyBen/packer-arch-vbox/releases

