@echo off
REM Enable Packer logging and run a clean build.
set PACKER_LOG=1
set PACKER_LOG_PATH=packer.log
packer.exe build -force .
