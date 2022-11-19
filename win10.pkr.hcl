packer {
	required_plugins {
		windows-update = {
			version = "0.14.1"
      		source = "github.com/rgl/windows-update"
		}
	}
}

source "vmware-iso" "vm"{
  # Required vars
  iso_checksum      = "${var.iso_checksum}"
  iso_url           = "${var.iso_url}"

  # WinRM connection information
  communicator      = "winrm"
  winrm_password                 = "${var.winrm_password}"
  winrm_timeout                  = "${var.winrm_timeout}"
  winrm_username                 = "${var.winrm_username}"

  # Allow vnc for debugging
  # NOTE Used for remote deployments
  vmx_data = {
    "RemoteDisplay.vnc.enabled" = "false"
    "RemoteDisplay.vnc.port"    = "5900"
  }
  vnc_port_max                   = 5980
  vnc_port_min                   = 5900

  # Optional vars
  boot_wait         = "5m"  # NOTE This needs to be set as Windows takes longer to finish initialization
  shutdown_command  = "shutdown /s /t 10 /f /d p:4:1"   # Graceful shutdown
  vmx_remove_ethernet_interfaces = true # NOTE Only used for building vagrant box images

  # Machine information
  vm_name           = "${var.vm_name}"
  cpus              = 2
  memory            = "${var.memory}"
  disk_adapter_type = "lsisas1068"
  disk_size         = "${var.disk_size}"
  guest_os_type     = "${var.guest_os_type}"
  headless          = "${var.headless}"
  floppy_files      = [ # NOTE The autounattend file must be specified
	"${var.autounattend}",
  	"./Scripts/Set-NetworkTypeToPrivate.ps1",
	"./Scripts/ConfigureWinRM.ps1"
  ]
}

build {
  sources = ["source.vmware-iso.vm"]

  # Disable internet explorer
  provisioner "powershell" {
	inline = [
		"Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online -NoRestart"
	]
  }

  # Update help information
  provisioner "powershell" {
	inline = [
		"Update-Help -UICulture en-us -ErrorAction Ignore -Force"
	]
  }

  # Run scripts
  provisioner "powershell" {
	scripts = [
		"./Scripts/Debloat-Windows.ps1",
		"./Scripts/Install-VMwareTools.ps1"
	]
  }

#   # Update Windows
#   provisioner "windows-update" {
# 	search_criteria = "IsInstalled=0"
#   }

  # Creat vagrant box
  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "win10_{{ .Provider }}.box"
    vagrantfile_template = "VagrantFile"
  }
}
