# Hackintosh-FX504GE-ES72
Mojave 10.14.6 (Clover) → Monterey/Ventura (OpenCore 1.0.6).  BIOS version 318

## Component Versions (OpenCore 1.0.6 build)

| Component | Version | Notes |
|-----------|---------|-------|
| OpenCore | 1.0.6 | Replaces 0.8.5 |
| Lilu | 1.7.1 | |
| VirtualSMC | 1.3.7 | +SMCBatteryManager/LightSensor/Processor/SuperIO |
| WhateverGreen | 1.7.0 | |
| AppleALC | 1.9.6 | layout-id 3 |
| AirportBrcmFixup | 2.2.0 | |
| BrcmPatchRAM | 2.7.1 | BlueToolFixup+BrcmBluetoothInjector+BrcmFirmwareData+BrcmPatchRAM3 |
| HibernationFixup | 1.5.4 | |
| RealtekRTL8111 | 3.0.0 | |
| VoodooPS2Controller | 2.3.7 | Keyboard only (trackpad disabled — using I2C) |
| VoodooI2C | 2.9.1 | +VoodooGPIO+VoodooI2CServices+VoodooInput |
| VoodooI2CHID | 2.9.1 | ELAN1200 satellite |
| USBPorts | 1.0 | Custom USB map for FX504GE — do not update |

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
- Intel Graphics Acceleration (UHD 630)
- Wi-Fi & Bluetooth (DW1560)
- Audio (Realtek ALC255, layout-id 3)
- Brightness control (Fn keys)
- Sleep and Wake (HibernateMode 3)
- PS/2 Keyboard
- HDMI port (stable with EDID patch + agdpmod=vit9696)
- Battery management
- USB ports (custom USBPorts.kext map)

# Not Working / In Progress
- I2C ELAN1200 Precision TouchPad — see **I2C TouchPad Fix** section below

# Installation — OpenCore 1.0.6 (recommended, opencore0.85/)

1. Create a macOS installer USB using `createinstallmedia`.
2. Mount your EFI partition and copy `opencore0.85/EFI/` to it.
3. Generate unique SMBIOS values (MacBookPro15,1) using [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS)
   and fill in `MLB`, `SystemSerialNumber`, `SystemUUID`, and `ROM` in `config.plist > PlatformInfo > Generic`.
4. Boot the installer, install macOS, then boot from the EFI partition.
5. For the I2C touchpad, compile and add `SSDT-GPI0.aml` — see **I2C TouchPad Fix** below.

**ACPI tables (OC):** SSDT-GPI0, SSDT-dGPU-Off, SSDT-EC-USBX-LAPTOP, SSDT-PLUG, SSDT-PMC, SSDT-PNLF-CFL, SSDT-XOSI

**Kexts (OC):** Lilu, VirtualSMC (+SMCBatteryManager/LightSensor/Processor/SuperIO), WhateverGreen, AppleALC,
AirportBrcmFixup, BlueToolFixup, BrcmFirmwareData, BrcmPatchRAM3, BrcmBluetoothInjector (≤Big Sur),
HibernationFixup, RealtekRTL8111, USBPorts, VoodooPS2Controller (+Keyboard), VoodooI2C (+VoodooInput), VoodooI2CHID

**UEFI Drivers (OC):** HfsPlus.efi, OpenCanopy.efi, OpenRuntime.efi

# OpenCore 1.0.6 Config (config085.plist / opencore0.85)
- SMBIOS: MacBookPro15,1
- Boot args: `-v keepsyms=1 debug=0x100 -wegnoegpu agdpmod=vit9696 -igfxblr igfxonln=1 igfxrpsc=1 igfxfw=2`
  (remove `-v` and debug flags once stable)
- ACPI Quirks: _OSI → XOSI rename (SSDT-XOSI simulation of Windows 10)
- Kernel Quirks: AppleXcpmCfgLock=true, DisableIoMapper=true, DisableLinkeditJettison=true,
  PowerTimeoutKernelPanic=true, XhciPortLimit=false (custom USBPorts.kext handles USB map)

# Installation — Clover (legacy, Mojave 10.14.6)

- 1.Use the Clover EFI Mojave Installer to install macOS Mojave (10.14.6)
- 2.Boot into the system and replace the "EFI" folder on your System Boot Disk EFI partition
- 3.Install all the kexts in `kexts/other/` into `/Library/Extensions`, rebuild kextcache and reboot
-     ACPI Patched: DSDT, SSDT-DDGPU, SSDT-PNLF/PNLFCFL, SSDT-UIAC, SSDT-XHC, SSDT-XOSI
      UEFI Drivers: ApfsDriverLoader, OsxAptioFix3Drv (Clover 5108), DataHubDxe, EmuVariableUefi,
			FSinject, HFSPlus or VBoxHFS, NvmExpressDxe, PartitionDxe, SMCHelper
      Kexts: ACPIBatteryManager, AirportBrcmFixup, AppleALC, BrcmFirmwareRepo, BrcmPatchRAM2,
			BT4LEContiunityFixup, FakeSMC, Lilu, NoTouchID, RealtekRTL8111, USBInjectAll,
			VoodooPS2Controller, WhateverGreen, XHCI-unsupported

# Clover Config (legacy)
- Acpi: AutoMerge, DSDT Patches (_OSI to XOSI, HECI to IMEI, GFX0 to IGPU, HDAS to HDEF), SSDT PluginType checked
- Boot Args: `dart=0 -igfxnohdmi darkwake=0 -v -lilubetaall keepsyms=1 -wegbeta`
- Kernel Patches: Kernel LAPIC, KernelPM and AppleRTC enabled
- SMBIOS: MacBookPro15,2
- SystemParameters: InjectKexts Detect, InjectSystemID YES

# I2C TouchPad Fix (ELAN1200 Precision TouchPad)

The ELAN1200 is an I2C HID device that needs the Intel GPIO controller active
under macOS for interrupt-driven operation. Without it, VoodooI2C cannot
establish an interrupt and the touchpad stays unresponsive.

**What was already in place:**
- `VoodooI2C.kext` + `VoodooI2CHID.kext` in OC/Kexts/
- `SSDT-XOSI.aml` (Windows 10 simulation, required by VoodooI2C)
- `_OSI → XOSI` ACPI rename patch

**Fixes applied in this commit:**
1. `VoodooInput.kext` (VoodooI2C plugin) — was **disabled**, now **enabled**.
   VoodooInput provides the trackpad gesture translation layer; without it
   multi-touch and any gesture data never reach macOS.
2. `VoodooPS2Trackpad.kext` — was **enabled**, now **disabled**.
   Leaving the PS/2 trackpad driver active alongside VoodooI2CHID causes a
   driver conflict; whichever binds first blocks the other.
3. `SSDT-GPI0.aml` added to `ACPI > Add` in config.plist.
   Enables `_SB.PCI0.GPI0` under Darwin so the GPIO controller is visible
   to VoodooI2C for interrupt-based I2C communication.

**One manual step required — compile SSDT-GPI0.dsl:**

The DSL source is at `opencore0.85/EFI/OC/ACPI/SSDT-GPI0.dsl`.
You must compile it to produce the binary `SSDT-GPI0.aml`:

```bash
# Option A — command line (install iasl via Homebrew: brew install acpica)
iasl -G opencore0.85/EFI/OC/ACPI/SSDT-GPI0.dsl
# This creates SSDT-GPI0.aml in the same folder.

# Option B — MaciASL (GUI)
# Open SSDT-GPI0.dsl in MaciASL and File > Save As... ACPI Machine Language Binary (.aml)
# Save to opencore0.85/EFI/OC/ACPI/SSDT-GPI0.aml
```

After compiling, `SSDT-GPI0.aml` must be present in `EFI/OC/ACPI/` on your
EFI partition. The `config.plist` entry is already in place.

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
      
# Fix HDMI-not-stable Problem.

      Please follow below steps to solve the hdmi-unstable problem.
      1.change smbios to macbook pro 15,1.
      2.use the boot-args:-v -wegnoegpu agdpmod=vit9696 -igfxblr igfxonln=1 igfxrpsc=1 igfxfw=2
      3.patch the EDID of both your build-in monitor and external monitor.
         Firstly, use Hackintool to patch all your connected monitors(for build-in 16:9 screen,choose macbook air). 
	 The corresponding EDID.bin files will be created on your desktop.
         Secondly,use AW EDID Editor to modify your preferred timing parameters(in Detailed Descriptor section).
	 Use Video Timings Calculator to find the timings for different standard.You should creat three EDID.bin files 
	 for the timings in relation to CVT-RB,CVT-RBv2, and CEA-861,respectively.  (you could also use the build-in 
	 CVT Format wizard in the section Detailed Descriptor of AW EDID Editor,which could creat v1 and v2 CVT timings;
	 or Use predefined format to creat CEA-861 timings)
         Thirdly, Use BetterDisplay to apply HIDPI for your external monitor. At the mean time, upload the patched 
	 EDID.bin files for both your build-in and external monitor. Apply the changes and restart your computer, 
	 BetterDisplay will do the remain work for you.
     4.Find the suitable EDID.bin file for your external monitor. For my LG 21:9 monitor, the best timing is CVT-RBv2 
         for 2560*1080 at 60Hz.
     5.USE xxd -ps edid_bin.bin > edid_hex_modified.txt to creat hex. put the relevent hex in your config.plist under 
     section AAPL00,override-no-connect and AAPL01,override-no-connect

      https://tomverbeure.github.io/video_timings_calculator
      https://github.com/waydabber/BetterDisplay
      https://www.analogway.com/apac/training-support/telechargements/aw-edid-editor/id:356/
      https://www.monitortests.com/forum/Thread-Custom-Resolution-Utility-CRU?page=1
      
      
      
      
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
