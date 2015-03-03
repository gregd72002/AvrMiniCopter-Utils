#!/bin/sh

while [ 1 ]; do
	sleep 1;
	if [[ -z "$(pidof hostapd)" ]]; then 
		killall dnsmasq
		echo "Creating AccessPoint"
		ifconfig wlan0 down
		hostapd -B /etc/hostapd.conf
		ifconfig wlan0 10.0.2.1 netmask 255.255.255.0 up
		dnsmasq -i wlan0 -I lo -z --dhcp-range=10.0.2.2,10.0.2.10,1h
		echo "AP created"
	fi
done
