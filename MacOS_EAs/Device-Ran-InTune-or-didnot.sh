#!/bin/bash

#Jamf EA to find if a device has run the company portal Join
#Please note, This may not be 100% true for measuring compliance. please rely on the device record in Jamf and the device record in Azure/Intune
#Please not file paths are subject to change because CompanyPortal Application is not owned by Jamf 
#Removed Python
#Added method for getting home folders 
currentuser=$(stat -f "%Su" /dev/console)
user_path=$(echo ~${currentuser})
#Lets check for the file

if [ -f "${user_path}/Library/Application Support/com.microsoft.CompanyPortalMac.usercontext.info" ]; then
	echo "<result>Machine is Intuned</result>"
	else
		echo "<result>Machine is not InTuned</result>"
fi
exit
