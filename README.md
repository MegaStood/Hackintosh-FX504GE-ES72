# Hackintosh-FX504GE-ES72
Mojave 10.14.2


dubug command
1.  sudo pmset -g log | grep -i failure
2019-01-18 16:45:03 +0800 Failure             	Sleep Failure [code:0xFFFFFFFF0000001F]:
It mentions GLAN, which of course is gigabit LAN. You may want to double check your bios settings and make sure 'Wake-On-Lan' is NOT enabled. That is known to break sleep on some systems. It might help you narrow things down a bit anyway.
2.  sudo pmset -g assertions
2019-01-24 15:06:10 +0800 
Assertion status system-wide:
   BackgroundTask                 0
   ApplePushServiceTask           0
   UserIsActive                   1
   PreventUserIdleDisplaySleep    0
   PreventSystemSleep             0
   ExternalMedia                  0
   PreventUserIdleSystemSleep     0
   NetworkClientActive            0
Listed by owning process:
   pid 97(hidd): [0x000000170009802d] 00:00:00 UserIsActive named: "com.apple.iohideventsystem.queue.tickle.4294968110.3" 
	Timeout will fire in 10800 secs Action=TimeoutActionRelease
Kernel Assertions: 0xc=USB,BT-HID
   id=500  level=255 0x4=USB mod=1/1/1970, 8:00 AM description=com.apple.usb.externaldevice.14500000 owner=BCM20702A0
   id=501  level=255 0x4=USB mod=1/1/1970, 8:00 AM description=com.apple.usb.externaldevice.14400000 owner=USB2.0 HD UVC WebCam
   id=502  level=255 0x4=USB mod=1/1/1970, 8:00 AM description=com.apple.usb.externaldevice.14100000 owner=USB Optical Mouse
   id=503  level=255 0x8=BT-HID mod=1/1/1970, 8:00 AM description=com.apple.driver.IOBluetoothHIDDriver owner=BNBTrackpadDevice
Idle sleep preventers: IODisplayWrangler
IODisplayWrangler

3.log show --predicate 'process == "kernel"' --style syslog --source --debug --last 10m > ~/sys_log.txt

4.log show --predicate "processID == 0" --start $(date "+ %Y-%m-%d") --debug | less

5.
