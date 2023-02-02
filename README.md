# Purpose

Create a perfect WIM everytime ;)

## Pre-Requisites

- [Packer](https://developer.hashicorp.com/packer/downloads)
- [VMware](https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html)
- [OSFMount](https://www.osforensics.com/tools/mount-disk-images.html)
- One of the following must be installed and added to your **PATH** environment variable. (This is due to how packer encapsulates our boot files into an ISO in order to mount them. Documentation [here](https://developer.hashicorp.com/packer/plugins/builders/vmware/iso#cd-configuration:~:text=Use%20of%20this,the%20Windows%20ADK))
  - [xorriso](https://www.gnu.org/software/xorriso/)
  - [mkisofs](https://linux.die.net/man/8/mkisofs)
  - [hdiutil](https://ss64.com/osx/hdiutil.html) (normally found in macOS)
  - [oscdimg](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options?view=windows-11) (normally found in Windows as part of the Windows ADK)

## Quick Start

- Change into the project directory and execute `packer init .` (This will download all missing plugins)
- Now as an administrator run the build script `Build-PackerImage.ps1`

## Customizing

### OEM Information

Custom OEM information can be configured in the respective answer file located [here](./Answers/)

## Building

In order to build the image you can run the `.\Build-PackerImage.ps1` located at the root of the repository.

## Testing

If you would like to run a specific step you can comment (`#`) out the `Start-Process @step<StepNumber>Args`, save and then run the powershell script.

---

**Note**

Due to how sysprep is implemented the built in 'Administrator' and 'Guest' account will always be renamed to their default 'values'. This is the reason we do not rename the built-in accounts.

---
