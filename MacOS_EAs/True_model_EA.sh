#!/bin/bash
#Version 1
#True_model_EA for Jamf Pro
#Please note that this may stop working at any time if Apple change their pages or puts a capture infront of it. KEEP IN MIND
#Created 23rd of October 2020


####SCRIPT#######
## Get the Serial Number
SerialNum=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformSerialNumber/{print $4}')

## Check the length of the serial number and set an appropriate string to use for the lookup
if [[ ${#SerialNum} -ge 12 ]]; then
	Serial=$(echo "$SerialNum" | tail -c 5)
else
	Serial=$(echo "$SerialNum" | tail -c 4)
fi

##Send the serial number to apple to pull in the machine model live. 
FullModelName=$(curl -s "https://support-sp.apple.com/sp/product?cc=${Serial}" | xmllint --format - 2>/dev/null | awk -F'>|<' '/<configCode>/{print $3}')

echo "<result>${FullModelName}</result>"
