#!/bin/ash
# RPi Network Conf Bootstrapper

ssid="MY_WIFI_SSID"

ERROR=$(ifconfig wlan0 2>&1 >/dev/null)
ERROR=`echo $ERROR | grep error`;
while [ "$ERROR" != "" ]; do
	sleep 3
	ERROR=$(ifconfig wlan0 2>&1 >/dev/null)
	ERROR=`echo $ERROR | grep error`;
done

echo "Found WIFI device"

createAdHocNetwork(){
    echo "Creating ad-hoc network"
    ifconfig wlan0 down
    iw wlan0 set type ibss
    ifconfig wlan0 up 
    iw wlan0 ibss join RpiCopter 2412 key d:0:01234
    ifconfig wlan0 10.0.2.1 netmask 255.255.255.0 up
    dnsmasq -i wlan0 -I lo -z --dhcp-range=10.0.2.2,10.0.2.10,1h
    echo "Ad-hoc network created"
}

createAPNetwork(){
    /usr/local/bin/wifi-AP.sh &
}

createSoftAPNetwork() {
    echo "Creating AccessPoint"
    modprobe tun
    ifconfig wlan0 down
    iw phy phy0 interface add moni0 type monitor
    airbase-ng -e RPiCopterAP1 -c 6 moni0 &
    ifconfig at0 10.0.2.1 netmask 255.255.255.0 up
    dnsmasq -i at0 -I lo -z --dhcp-range=10.0.2.2,10.0.2.10,1h
}

echo "================================="
echo "RPi Network Conf Bootstrapper 0.1"
echo "================================="
echo "Scanning for known WiFi networks"
connected=false

iw phy phy0 set coverage 2 #distance up to 900m
iw phy phy0 set txpower fixed 3000

ifconfig wlan0 up
if iw wlan0 scan | grep $ssid > /dev/null
then
	echo "First WiFi in range has SSID:" $ssid
	/usr/local/bin/wifi-Client.sh &
else
	echo "Not in range, WiFi with SSID:" $ssid
	createAPNetwork
#        createSoftAPNetwork
#        createAdHocNetwork
fi
 
exit 0

