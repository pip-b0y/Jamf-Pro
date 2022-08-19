#!/bin/bash
#Script is As is, test this out before moving to production. No warrenty.
#For usuage in scripts see https://docs.jamf.com/10.28.0/jamf-pro/administrator-guide/Computer_Configuration_Profiles.html
#For best usage, create a smart group to find devices that return AdapterNotFound to be excluded in deployment of profiles that are using the reported macAddress. 
#
#
#
#This is going to be the name of the removable network adapter that end user are using to connect to the network, can break if users change its name in system preferences. 
adaptername=''


macaddress=$(networksetup -listallhardwareports | grep -A 3 "${adaptername}" | grep "Ethernet Address:" | awk '{ print $3}')

if [ -z ${macaddress} ]; then

echo "<result>AdapterNotFound</result>"

else

echo "<result>${macaddress}</result>"

fi
