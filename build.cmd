@echo off
set PACKER_LOG=1
set PACKER_LOG_PATH=packer.log
packer.exe build -force .
