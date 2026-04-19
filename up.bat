@echo off

set VM_NAME=arch-linux
echo Starting Arch Linux Headless...
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "%VM_NAME%" --type headless
echo Done.
