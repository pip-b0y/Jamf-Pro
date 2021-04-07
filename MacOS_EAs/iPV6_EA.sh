#!/bin/bash
##Created by pip-b0y
###this is a as is ea.
###please note if a user renames a adapter in System Prefs. This EA might not work correclty. Will get the active adapter


active_interface=$(route get default | grep interface | awk '{print $2}')
active_network_name=$(networksetup -listallhardwareports | grep -B 1 "${active_interface}" | awk '/Hardware Port/{ print }'|cut -d " " -f3-)
ipv6_address=$(networksetup -getinfo "${active_network_name}" | grep "IPv6 IP address:" | cut -d " " -f4)

##send to Jamf when recon is ran
echo "<result>${ipv6_address}}</result>"
