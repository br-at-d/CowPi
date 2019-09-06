#!/bin/bash

# references the interface
wlaninterface=wlan0

# add the mon the the interface name for use with airmon-ng and airodump-ng
m=mon
i=$wlaninterface$m

# sets the base file name for the wireless survey
recon=/DaCaps/scouted

# sets the file name for the pcap file to write too
pcapfile=/DaCaps/DaCapFile

# sets the length of time to run the survey for – in seconds
recontime=120s

# sets the length of time to run the packet capture for – in seconds
capturetime=3600s

# general house cleaning to remove previous captures
rm $recon*.csv &> /dev/null
rm $pcapfile*.cap &> /dev/null

# setting wlan0 into monitor mode
airmon-ng check kill &
airmon-ng start $wlaninterface &

# running the wireless survey for the defined amount of time the stops the process
airodump-ng -w $recon –output-format csv $i &> /dev/null &
sleep $recontime
kill $!

# finds the open WiFi network with the most active traffic and get the channel number
channel=$(grep -a ‘OPN’ $recon*.csv | sort -nrk11 | tail -1 | awk ‘{print $6}’)

# removes the comma from the output of the previous line
ch=${channel::-1}

#running the packet capture for the defined amount of time the stops the process
airodump-ng –encrypt OPN –output-format pcap –channel $ch -w $pcapfile $i &> /dev/null &
sleep $capturetime
kill $!

# our work here is done, time to take a nap
Shutdown -P now
