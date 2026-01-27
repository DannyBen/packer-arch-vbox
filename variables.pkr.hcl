variable "vm_name" {
  description = "The name of the VM in VirtualBox"
  type        = string
  default     = "arch-linux"
}

variable "shared_folder_hostpath" {
  description = "The path on your computer to share with the VM"
  type        = string
  default     = "."
}

variable "cpus" {
  description = "Number of virtual CPUs allocated to the guest."
  type        = number
  default     = 4
}

variable "memory" {
  description = "Memory in MB allocated to the guest."
  type        = number
  default     = 8192
}

variable "disk_size" {
  description = "Disk size in MB for the virtual disk."
  type        = number
  default     = 40000
}
