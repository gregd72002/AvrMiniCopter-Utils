#!/bin/sh
 
driver=$1
 
while [ 1 ]; do
        sleep 1;
        if [ -z "$(pidof wpa_supplicant)" ] ; then
                killall udhcpc
                killall wpa_supplicant
                echo "Connecting to an AccessPoint"
                echo "Starting supplicant for WPA/WPA2 and $driver"
                wpa_supplicant -B -D $driver -i wlan0 -c /etc/wpa_supplicant.conf > /dev/null 2>&1
        fi      
        if [ -z "$(pidof udhcpc)" ] ; then
                echo "Obtaining IP from DHCP"                                                    
                udhcpc -i wlan0 -n
        fi
 
        RSSI=`wpa_cli signal_poll | sed -n 's/AVG_RSSI=//p'`
        echo "3 249 $RSSI" > /dev/avrspi_cmd
done

