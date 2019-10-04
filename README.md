# Hackintosh-FX504GE-ES72
Mojave 10.14.6.   Bios version 318

# Hardware Configuration
ASUS FX504GE-ES72:
- Intel i7-8750H
- 16GB RAM
- Samsung 970 evo 512GB NVMe SSD (Amazon)
- Dell DW1560(BCM94352Z) Wireless+Bluetooth (taobao)
-     Wi-Fi shows as Airport Extreme-- using AirportBrcmFixup.kext+Lilu(1.2.6)
      Bluetooth chipset 20702A3--using BrcmPatchRAM2.kext+BrcmFirmwareRepo.kext
- Apple Magic Mouse

# Working
- Intel Graphics Accelleration(uhd630)
- Wifi & Bluetooth (dw1560)
- Audio
- Brightlight Control
- Sleep and Wake (Hibernatemode 3)
- PS/2 Keyboard
- Work almost perfect
- HDMI port

# Not Working
- I2C ELAN1200 Precision TouchPad 

# Installation

- 1.Use the Clover EFI Mojave Installer to install Mac OS Majave(10.14.6) 
- 2.Boot into the system and replace the "EFI" Folder on you System Boot Disk EFI partition 
- 3.Install all the kext contained in the Kext "other" folder into your /Library/Extensions, rebuild kextcache and reboot
-     ACPI Patched: DSDT, SSDT-DDGPU, SSDT-PNLF/PNLFCFL, SSDT-UIAC, SSDT-XHC, SSDT-XOSI
      UEFI Drivers are used: ApfsDriverLoader, OsxAptioFix3Drv(clover 5108 stock,work fine), DataHubDxe, EmuVariableUefi, 
			FSinject, HFSPlus or VBoxHFS, NvmExpressDxe, PartitionDxe, SMCHelper.
      Kexts are used: ACPIBatteryManager, AirportBrcmFixup, AppleALC, BrcmFirmwareRepo, BrcmPatchRAM2, 
			BT4LEContiunityFixup, FakeSMC, Lilu, NoTouchID, RealtekRTL8111, USBInjectAll, 
			VoodooPS2Controller, WhateverGreen, XHCI-unsupported.
			
# Clover Config
- Acpi: AutoMerge, DSDT Patches(_OSI to XOSI, HECI to IMEI,GFX0 to IGPU, HDAS to HDEF,no need to rename EHC* as Chipsets post Skylake removed USB2.0 native support), SSDT PluginType checked 
- Boot Args: dart=0 -igfxnohdmi darkwake=0 -v -lilubetaall keepsyms=1 -wegbeta
- Kernel Patches: Kernel LAPIC, KernelPM and AppleRTC enabled
- SMBIOS: MacBookPro15,2
- SystemParameters: InjectKexts Detect, InjectSystemID YES.

# DSDT Patch (only two static patches needed )
##    Sleep and wake
    Use "USB _PRW 0x6D (instant wake)" patches for Skylake(and later). This patch will add 
		Method(_PRW) { Return(Package() { 0x6D, 0 }) } to relevant Devices.
    There may be missing a "}" after applying the patch, which cause compile syntax error. 
		Search for Method(_PRW) and find out the syntax error. If there is still wake problems 
		(“wake reason” :XDCI CNVW XHC etc.), use Log Show to find the wake reason and search the
		specific Device (XDCI or CNVW) to see if Method(_PRW) is missing in the specific device.
    
##    Brightness adjustment keys
    working by modifying /EFI/Clover/ACPI/patched/DSDT.aml
     Scope (_SB.PCI0.LPCB.EC0) {
     ...
     Method (_Q11, 0, NotSerialized)  // _Qxx: EC Query
     {
         Notify (PS2K, 0x0405) // Brightness down
     }
     Method (_Q12, 0, NotSerialized)  // _Qxx: EC Query
     {
         Notify (PS2K, 0x0406) // Brightness up
     }
     ...
     }

##    Hot Patches -
     1.Disable NV GPU: SSDT-DDGPU
     2.Backlight Control: SSDT-PNLF/PNLFCFL
     3.Removing unused USB ports: SSDT-UIAC
     4.inject properties for XHCI: SSDT-XHC
     5.XOSI simulation to "Windows 10": SSDT-XOSI

# USB

##    Actual Port Information:

      Port		       Type	            Description
      HS01/SS01  USB 3.0 Type A	    Front--Left side
      HS02/SS02	 USB 3.0 Type A	    Middle--Left side
      HS03	     USB 2.0	          Rear--Left Side
      HS07	     Proprietary	      Webcam
      HS14	     Proprietary	      Bluetooth

      Use above information to make specific Hotpatch SSDT-UIAC.aml(based on SSDT-UIAC-ALL).     

# Audio
      Realtek ALC255: Use AppleALC.kext, Clover Audio injection =3
     
# HDMI
      USE the latest Hacktool to creat a patch,the below section should be take care:      
      
      framebuffer-con1-busid                        01000000(the only work-out id) 
      framebuffer-con1-enable                       01000000
      framebuffer-con1-flags                        87010000
      framebuffer-con1-has-lspcon                   01000000
      framebuffer-con1-index                        01000000
      framebuffer-con1-pipe                         12000000
      framebuffer-con1-preferred-lspcon-mode        01000000
      framebuffer-con1-type                         00080000(used as a HDMI identifier),
      framebuffer-patch-enable                      01000000

      As the MacbookPro 15,2 do not have HDMI port actually, the check of the board-id should be ignored by 
      using the WhateverGreen boot-arg agdpmod=vit9696.please check the details in my updated config.plist.
      Kindly note that the kext of WhateverGreen, Lilu and AppleALC should be updated to the latest version. 
      
# Credit:
- Special thanks to RehabMan for his splendid work and comprehensive guidelines to Hackintosh laptops.
  His method make this model works almost perfect.
- Thanks to Jaymonkey for his iDiot's Guide to Lilu and its Plug-ins.
- Thanks to P1LGRIM for his iDiot's Guide To make iMessage work.
- Thanks to PoomSmart for his preliminary work, which inspire me to work further and make this final build. 

# Useful Links:
https://www.tonymacx86.com/threads/guide-booting-the-os-x-installer-on-laptops-with-clover.148093/
https://www.tonymacx86.com/threads/guide-patching-laptop-dsdt-ssdts.152573/
https://www.tonymacx86.com/threads/broadcom-wifi-bluetooth-guide.242423/#post-1664577
https://www.tonymacx86.com/threads/guide-creating-a-custom-ssdt-for-usbinjectall-kext.211311/
https://www.tonymacx86.com/threads/guide-10-11-usb-changes-and-solutions.173616/
https://www.tonymacx86.com/threads/guide-using-clover-to-hotpatch-acpi.200137/

https://www.tonymacx86.com/threads/an-idiots-guide-to-lilu-and-its-plug-ins.260063/
https://www.tonymacx86.com/threads/an-idiots-guide-to-imessage.196827/

https://github.com/RehabMan/Laptop-DSDT-Patch
https://github.com/RehabMan/OS-X-Clover-Laptop-Config
https://github.com/RehabMan/OS-X-USB-Inject-All

# Dubug Command
     1.  sudo pmset -g log | grep -i failure
     2.  sudo pmset -g assertions
     3.  log show --predicate 'process == "kernel"' --style syslog --source --debug --last 10m > ~/sys_log.txt
     4.  log show --predicate "processID == 0" --start $(date "+ %Y-%m-%d") --debug | less
     5.  log show --style syslog --last 120m | fgrep "Wake reason"
