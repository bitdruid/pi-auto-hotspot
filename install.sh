#!/bin/bash

# check if root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

echo ''
echo '=== DEPENDENCIES ==='
echo 'Installing:'
echo '-samba'
echo '-hostapd'
echo '-dnsmasq'
echo '-nmap'
echo '-dhcpcd5'
echo ''
read -p 'proceed? (y/n)' selection
echo ''
if [[ $selection != "y" ]]; then
    echo 'aborting...'
    exit 1
fi
packages=(samba hostapd dnsmasq nmap dhcpcd5) #tor)
# install missing packages
for package in "${packages[@]}"; do
    if ! dpkg -s "$package" >/dev/null 2>&1; then
        echo "Installing $package"
        sudo apt-get install "$package"
    fi
done

echo ''
echo '=== INSTALLATION ==='

#rules
chown -R root:root *
chmod 0755 command/* 
chmod 0644 config/* systemd/* udev/*

#command scripts
sudo cp command/hotspot /usr/bin/hotspot
sudo cp command/wpamod /usr/bin/wpamod
sudo cp command/automount /usr/bin/automount

#configs, services and rules
sudo cp systemd/hotspot.service /etc/systemd/system
sudo cp systemd/hotspot.timer /etc/systemd/system
sudo cp udev/85-automount.rules /etc/udev/rules.d
sudo cp systemd/automount@.service /lib/systemd/system
if ! [ -f /etc/samba/smb.conf ]; then
    sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
fi
sudo cp config/smb.conf /etc/samba/smb.conf
sudo cp config/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp config/dnsmasq.conf /etc/dnsmasq.conf

#replace DAEMON_CONF /etc/default/hostapd 
sudo sed -i 's/^#DAEMON_CONF="".*$/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

#predictable network interface names
if [[ ! -L /etc/udev/rules.d/80-net-setup-link.rules ]]; then
    sudo ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
fi

#prepare udevrule
if ! [[ $(grep -o "MountFlags=shared" /lib/systemd/system/systemd-udevd.service) ]]; then
    sudo bash -c 'echo "MountFlags=shared" >> /lib/systemd/system/systemd-udevd.service'
    udevadm control --reload-rules && udevadm trigger
fi

#prepare wpa_supplicant
if [ ! -f /etc/wpa_supplicant.conf ]; then
    cp misc/wpa_supplicant.conf.empty /etc/wpa_supplicant/
fi
sudo cp /etc/wpa_supplicant/wpa_supplicant.conf.empty /etc/wpa_supplicant/wpa_supplicant.conf

#prepare services
sudo systemctl unmask hostapd.service
sudo wpamod -disable
sudo systemctl enable --now hotspot.service
sudo systemctl enable --now hotspot.timer
sudo systemctl enable --now dhcpcd.service
sudo systemctl disable --now dnsmasq.service
sudo systemctl disable --now hostapd.service

echo ''
echo '=== DONE ==='
echo ''
