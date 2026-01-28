@echo off
:: Check for Admin rights and elevate if needed
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Starting Arch Linux Headless...
    "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "arch-linux" --type headless
) else (
    echo Requesting Administrative Privileges...
    powershell -Command "Start-Process -Verb RunAs '%0'"
    exit /b
)
