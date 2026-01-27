#!/bin/bash
set -e

# --- 1. Disk Preparation ---
echo "==> Preparing disk /dev/sda..."
wipefs -a /dev/sda
parted -s /dev/sda mklabel msdos
parted -s -a optimal /dev/sda mkpart primary ext4 0% 100%
parted -s /dev/sda set 1 boot on
udevadm settle

echo "==> Formatting and mounting /dev/sda1..."
mkfs.ext4 -F /dev/sda1
mount /dev/sda1 /mnt

# --- 2. Base Installation ---
echo "==> Installing base system and essential packages..."
pacstrap /mnt base linux linux-firmware base-devel grub networkmanager openssh virtualbox-guest-utils

echo "==> Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
# Configure shared folder mount point for VirtualBox
echo "vagrant /vagrant vboxsf defaults,uid=1000,gid=1000,dmode=775,fmode=775,nofail,_netdev 0 0" >> /mnt/etc/fstab

# --- 3. System Configuration ---
echo "==> Configuring system settings and bootloader..."
arch-chroot /mnt bash -c "echo 'KEYMAP=us' > /etc/vconsole.conf"
arch-chroot /mnt bash -c "echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub"

arch-chroot /mnt bash -c "grub-install --target=i386-pc /dev/sda"
arch-chroot /mnt bash -c "grub-mkconfig -o /boot/grub/grub.cfg"

echo "==> Enabling system services..."
arch-chroot /mnt systemctl enable NetworkManager sshd vboxservice

# --- 4. User & Security Setup ---
echo "==> Creating users and configuring permissions..."
# Set root password
arch-chroot /mnt bash -c "echo 'root:root' | chpasswd"

# Create vagrant user with sudo access
arch-chroot /mnt bash -c "useradd -m -G wheel -s /bin/bash vagrant"
arch-chroot /mnt bash -c "echo 'vagrant:vagrant' | chpasswd"
arch-chroot /mnt bash -c "echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel"

# Prepare shared folder directory
arch-chroot /mnt mkdir -p /vagrant
arch-chroot /mnt chown vagrant:vagrant /vagrant

# --- 5. Cleanup & Optimization ---
echo "==> Purging pacman cache..."
arch-chroot /mnt pacman -Scc --noconfirm

# Optional: Zero out the drive to optimize final image compression
# This can be time-consuming; enable only if minimal artifact size is required.
if [ "$COMPRESS" = "true" ]; then
  echo "==> Zeroing out the drive for maximum compression..."
  dd if=/dev/zero of=/mnt/EMPTY bs=1M || true
  rm /mnt/EMPTY
fi

echo "==> Unmounting and finalizing..."
sync
umount -R /mnt

echo "Installation Complete."