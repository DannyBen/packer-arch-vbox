@echo off

set VM_NAME=arch-linux
set VBOX="C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

echo Sending ACPI shutdown signal to %VM_NAME%...
%VBOX% controlvm "%VM_NAME%" acpipowerbutton

echo Done.
