#!/bin/bash

# check if root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

echo ''
echo '=== UNINSTALLATION ==='
echo 'Uninstalling:'
echo '-samba'
echo '-hostapd'
echo '-dnsmasq'
echo '-nmap'
echo '-dhcpcd5'
#echo '-tor'
echo ''
read -p 'proceed? (y/n)' selection
echo ''
if [[ $selection != "y" ]]; then
    echo 'aborting...'
    exit 1
fi
packages=(samba hostapd dnsmasq nmap dhcpcd5) #tor)
# uninstall packages
for package in "${packages[@]}"; do
    if dpkg -s "$package" >/dev/null 2>&1; then
        echo "Uninstalling $package"
        sudo apt-get remove --purge "$package" -y
    fi
done

echo '=== CLEANUP ==='
# cean up configuration files, services, and rules

# remove systemd services
sudo systemctl stop hotspot.service
sudo systemctl disable hotspot.service
sudo rm /etc/systemd/system/hotspot.service

# remove udev rules
sudo rm /etc/udev/rules.d/85-automount.rules

# restore the original smb.conf if it was backed up
if [ -f /etc/samba/smb.conf.bak ]; then
    sudo mv /etc/samba/smb.conf.bak /etc/samba/smb.conf
fi

# restore the original DAEMON_CONF in /etc/default/hostapd
sudo sed -i 's/^DAEMON_CONF="\/etc\/hostapd\/hostapd.conf".*$/#DAEMON_CONF=""/g' /etc/default/hostapd

# remove predictable network interface symbolic link
if [[ -L /etc/udev/rules.d/80-net-setup-link.rules ]]; then
    sudo rm /etc/udev/rules.d/80-net-setup-link.rules
fi

# remove "MountFlags=shared" from systemd-udevd.service
if [[ $(grep -o "MountFlags=shared" /lib/systemd/system/systemd-udevd.service) ]]; then
    sudo sed -i '/MountFlags=shared/d' /lib/systemd/system/systemd-udevd.service
    udevadm control --reload-rules && udevadm trigger
fi

# remove the modified wpa_supplicant.conf
if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ]; then
    sudo rm /etc/wpa_supplicant/wpa_supplicant.conf
fi

# disable and stop remaining services
sudo systemctl mask hostapd.service
sudo wpamod -enable
sudo systemctl disable --now dhcpcd.service
sudo systemctl stop dhcpcd.service
sudo systemctl disable --now dnsmasq.service
sudo systemctl stop dnsmasq.service

# remove command scripts
sudo rm /usr/bin/hotspot
sudo rm /usr/bin/wifi
sudo rm /usr/bin/wpamod
sudo rm /usr/bin/automount
sudo rm /usr/bin/logclean
#sudo rm /usr/bin/torcontrol
#sudo rm /usr/bin/routecontrol

echo ''
echo '=== DONE ==='
echo ''
