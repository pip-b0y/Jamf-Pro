#!/bin/bash
#Created by pip-b0y
#Name: BulkUnmange
#Version: 0.2
#UseCase: For removing the MDM Profile from DEP devices that have it un-removable via the user end. It is best to be used by orgs that have decided to sell user used devices to end users and dont want to fuss with wiping the device. Bulk unmange is the key here. 
#
#Can Remove the mdm profile from devices that are in a Group in Jamf Pro
#This uses the Built in API in Jamf Pro. 
#Script is as is
#Intended for Jamf Pro admins that know what they are doing:
#Varibles NotChanged
unmanage_list=$(cat /tmp/device_list.xml)
onetimecode=$(cat /dev/urandom | base64 | head -c 8 2>&1)
#SCRIPT WARNING#
echo "This script here will unmanage devices that are members of a computer group. Please use caution this is not reversable"
read -n 1 -s -p "Shall we procceed? Press any key to begin close Terminal to exit. "
#SCRIPT Varibles
read -p "what is your Jamf pro URL with https://? " jamfurl
read -p "what is your Jamf Pro user Name?: " jamfuser
read -s -p "what is the password: " jamfpass
read -p "What is the name of the Computer group that is goign to be un-manged: " jamfgroup
clear
#SCRIPT begin
#make Jamf Group API Friendly
jamfgroup_api=$(echo $jamfgroup | sed 's/ /%20/g')
#
#Lets makes sure you really want to do this via a script. 
raw_data=$(curl -H "Accept: application/xml" -ku $jamfuser:$jamfpass $jamfurl/JSSResource/computergroups/name/$jamfgroup_api -X GET | xmllint --format - > /tmp/devices.xml)
device_names_raw=$(cat /tmp/devices.xml | xpath '//computer/serial_number' 2>&1 | awk -F '<serial_number>|</serial_number>' '{print $2}')
for device_name in $device_names_raw;do
	echo "$device_name" >> /tmp/device_list.xml
	done
###
	
echo "The following devices will be unmanaged:"
cat /tmp/device_list.xml
read -n 1 -s -p "Shall we procceed? Press any key to begin close Terminal to exit. "

###USER VERIFICATION####
echo "lets makes sure you want to do this. Your code for the day is $onetimecode"
read -p "Please Type in your one time code as is to prove you are human: " verifyuser
if [ "$verifyuser" = "$onetimecode" ]; then
	echo "Thank you code is good i will run the script"

#SCRIPT IF CODE PASSES
#Lets get a list of devices
device_id_raw=$(curl -H "Accept: application/xml" -ku $jamfuser:$jamfpass $jamfurl/JSSResource/computergroups/name/$jamfgroup_api | xpath '//computer/id' 2>&1 | awk -F '<id>|</id>' '{print $2}')
for device_id in $device_id_raw;do
	curl -H "Accept: application/xml" -ku $jamfuser:$jamfpass $jamfurl/JSSResource/computercommands/command/UnmanageDevice/id/$device_id -X POST

	done



#IF CODE IS WRONG
else
echo "The code you entered was wrong. I am going to terminate my self now"
exit
fi
