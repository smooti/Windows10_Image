packer {
	required_plugins {
		windows-update = {
			version = "0.14.1"
      		source = "github.com/rgl/windows-update"
		}
	}
}

variable "autounattend" {
  type    = string
  default = "./AnswerFiles/10/autounattend.xml"
}

variable "disk_size" {
  type    = string
  default = "61440"
}

variable "disk_type_id" {
  type    = string
  default = "1"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:2FD924BF87B94D2C4E9F94D39A57721AF9D986503F63D825E98CEE1F06C34F68"
}

variable "iso_url" {
  type    = string
  default = "./Distros/Win10_21H2_x64_English.ISO"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "restart_timeout" {
  type    = string
  default = "5m"
}

variable "vhv_enable" {
  type    = string
  default = "false"
}

variable "virtio_win_iso" {
  type    = string
  default = "./VirtDrivers/virtio-win-0.1.225.iso"
}

variable "vm_name" {
  type    = string
  default = "win10Ref"
}

variable "vmx_version" {
  type    = string
  default = "14"
}

variable "winrm_password" {
  type    = string
  default = "1qaz2wsx!QAZ@WSX"
}

variable "winrm_timeout" {
  type    = string
  default = "6h"
}

variable "winrm_username" {
  type    = string
  default = "sap_admin"
}

source "vmware-iso" "vm"{
  boot_wait         = "6m"
  communicator      = "winrm"
  cpus              = 2
  disk_adapter_type = "lsisas1068"
  disk_size         = "${var.disk_size}"
  disk_type_id      = "${var.disk_type_id}"
  floppy_files      = [
	"${var.autounattend}",
  	"./Scripts/Set-NetworkTypeToPrivate.ps1",
	"./Scripts/ConfigureWinRM.ps1"
	]
  guest_os_type     = "windows9-64"
  headless          = "${var.headless}"
  iso_checksum      = "${var.iso_checksum}"
  iso_url           = "${var.iso_url}"
  memory            = "${var.memory}"
  shutdown_command  = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  version           = "${var.vmx_version}"
  vm_name           = "${var.vm_name}"
  vmx_data = {
    "RemoteDisplay.vnc.enabled" = "false"
    "RemoteDisplay.vnc.port"    = "5900"
  }
  vmx_remove_ethernet_interfaces = true
  vnc_port_max                   = 5980
  vnc_port_min                   = 5900
  winrm_password                 = "${var.winrm_password}"
  winrm_timeout                  = "${var.winrm_timeout}"
  winrm_username                 = "${var.winrm_username}"
}

build {
  sources = ["source.vmware-iso.vm"]

#   provisioner "windows-update" {
# 	search_criteria = "IsInstalled=0"
#   }

  provisioner "powershell" {
	scripts = [
		"./Scripts/Install-VmwareTools.ps1"
	]
  }

  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "windows10_{{ .Provider }}.box"
    vagrantfile_template = "VagrantFile"
  }
}