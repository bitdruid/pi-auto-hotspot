# usb, wifi and hotspot automation for raspberry-pi (portable pendrive-reader)

Scripts to open up a raspberry pi hotspot with automount of plugged pendrives and samba sharing.

Wifi control is completly given to the scripts. Predictable network interface names are activated. Partial use is not possible. Or by modifying manually.

## install and uninstall
run install.sh or uninstall.sh

```
[Service]
MountFlags=shared
```
is added to ```/lib/systemd/system/systemd-udevd.service``` for automount-script to work properly

IMPORTANT:
The script will use predictable network interface names and automatically activate them.

## wifi
Command for easy wifi-connection.

## automount
Automatically mount a plugged pendrive. The script will generate a mountpoint in ```/media/share```
This folder will be removed after device is unplugged and the folder is empty. 
The udev-rule ```85-automount.rules```is a neccessary component and will be placed at
```/etc/udev/rules.d/```

Adding ```sudo service udev restart``` @reboot (e.g. crontab) may help if it wont work on startup.

## wpamod
Was just usefull because sometimes wpa_supplicant needs to be disabled.

## hotspot
Generates an access-point with the raspberry. The script will also start samba-sharing.
With automount-script, this will transform the raspberry to a portable pendrive-reader. 
You can connect via hotspot and access any pendrive without the need of I/O (keyboard, display, etc.)
This script comes with basic configs for dhcpcd, dnsmasq and hostapd.