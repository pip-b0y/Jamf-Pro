#!/bin/bash
#
#
#
#
#Create a smart group based off the EA + Matches Regex. The Regex should be (with out quotes) ".secure token"
#Idea is you can create an advance search, with the EA ticked to create a report of everyday endusers of the device and their token status.
#AS IS SCRIPT
user=$(stat -f %Su /dev/console)
targethomepath=$(eval echo "~${user}")
tokenstatus=$(sudo dscl . -read ${targethomepath} AuthenticationAuthority | grep -o SecureToken)

if [ "${tokenstatus}" == "SecureToken" ]; then
#token found
	echo "<result>${user} has secure token"
else
	echo "<result>${user} has no token</result>"
fi
