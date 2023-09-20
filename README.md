# usb, wifi and hotspot automation for raspberry-pi (portable pendrive-reader)

Scripts to open up a raspberry pi hotspot with automount of plugged pendrives and samba sharing.

The raspberry will lose its common network functionality and will only be accessible via hotspot. This is usefull for headless pi's without a screen for ssh access while debugging a gpio project. (my usecase)

I may add functionality to use both at the same time by using different network interfaces. But this is not implemented yet. An old version was capable of this but it seems that dhcpcd@.service is not working properly anymore - at least i could not get it to work again.

## install and uninstall
run install.sh or uninstall.sh

### system modifications

```
[Service]
MountFlags=shared
```
is added to ```/lib/systemd/system/systemd-udevd.service``` for automount-script to work properly

```
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
```
adds a symlink to activate predictable network interface names.

## automount
Automatically mount a plugged pendrive. The script will generate a mountpoint in ```/media/share```
This folder will be removed after device is unplugged and the folder is empty. 
The udev-rule ```/etc/udev/rules.d/85-automount.rules``` is required for the system to recognize a plugged pendrive.

If automounting is not active on startup, simply try to add ```@reboot sudo service udev restart``` as a cronjob.

## wpamod
Was just usefull because sometimes wpa_supplicant needs to be disabled.

## hotspot

This script is designed to automate the management of an Access Point (AP) on a raspberry. It was designed to get an easy ssh access for headless pi.

- **Auto Mode:** The script can automatically detect the network state and take appropriate actions, such as opening an AP with Samba support or closing the AP when an external gateway is available.

- **Manual Control:** You can manually open or close the AP with optional parameters to specify the network interface and SSID.

- **Repair Functionality:** The script includes a repair function to check and fix the AP configuration if needed.

The script will also start a samba server to share a connected pendrive. The folder ```/media/share``` will be shared.
This will transform the raspberry to a portable pendrive-reader. Usefull for data transfer instead of scp or sshfs - you can connect via hotspot and access any pendrive on the go.

This script comes with basic configs for dhcpcd, dnsmasq and hostapd. It will overwrite existing configs but they are required for the script to work properly.