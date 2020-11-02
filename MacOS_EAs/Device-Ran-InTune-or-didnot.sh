#!/bin/bash

#Jamf EA to find if a device has run the company portal Join
#Please note, This may not be 100% true for measuring compliance. please rely on the device record in Jamf and the device record in Azure/Intune
#Please not file paths are subject to change because CompanyPortal Application is not owned by Jamf 
currentuser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Lets check for the file

if [ -f "/Users/$currentuser/Library/Application Support/com.microsoft.CompanyPortalMac.usercontext.info" ]; then
	echo "<result>Machine is Intuned</result>"
	else
		echo "<result>Machine is not InTuned</result>"
fi
exit