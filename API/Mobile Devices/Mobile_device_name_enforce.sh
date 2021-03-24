#!/bin/bash

###Vars
message="Device Name: [Info]"
workingpath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
currentuser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
######
scriptname="Name devices after network reset"
buttonreturned=$(/usr/bin/osascript -e "display dialog \"Running this script will send a device name command to the devices that are supervised. Please note this will run against every device in your Jamf Pro server and you should be testing this out if possible in another Jamf Instance. There might be issues with devices with spaces in the name. Please use caution and the script is as is.\" with title \"${scriptname}\" buttons {\"Cancel\",\"Go\"} default button {\"Go\"}")
	buttonresult=$(echo "${buttonreturned}" | /usr/bin/awk -F "button returned:|," '{print $2}')
###############################################################################################
if [ "${buttonresult}" = "Go" ]; then
	logger "${message} user has agreed and we will proceed "
	
jamfurlraw=$( /usr/bin/osascript -e "display dialog \"What is your Jamf Pro url\" default answer \"https://yourjamfurl.corp.net\" with title \"Jamf Pro URL\" buttons {\"Cancel\",\"submit\"} default button {\"submit\"}")	
jamfurl=$(echo "${jamfurlraw}" | /usr/bin/awk -F "text returned:|," '{print $3}')
	logger "${message} ${currentuser} entered ${jamfurl}"	
###############################################################################################
jamfuserraw=$(/usr/bin/osascript -e "display dialog \"Jamf Pro User Name\" default answer \"jamfadmin\" with title \"Jamf Pro Username\" buttons {\"Cancel\",\"submit\"} default button {\"submit\"}")
jamfuser=$(echo "${jamfuserraw}" | /usr/bin/awk -F "text returned:|," '{print $3}')
	logger "${message} ${currentuser} entered ${jamfuser}"
################################################################################################
	
###Jamf Password. We will verify the password!
###Password Prompt 1
#################################################################################################
jamfpass1raw=$(/usr/bin/osascript -e "display dialog \"please enter the password for ${jamfuser}\" with hidden answer default answer \"\" with title \"${jamfuser} password required\" buttons {\"Cancel\",\"submit\"} default button {\"submit\"}")
##Password Transform
jamfpass1=$(echo ${jamfpass1raw} | /usr/bin/awk -F "text returned:|," '{print $3}')
################################################################################################
###Password 2
jamfpass2raw=$(/usr/bin/osascript -e "display dialog \"Please confirm your password for ${jamfuser}\" with hidden answer default answer \"\" with title \"Password Confirmation for ${jamfuser}\" buttons {\"Cancel\",\"Confirm\"} default button {\"Confirm\"}")
###Password Transform
jamfpass2=$(echo ${jamfpass2raw} | /usr/bin/awk -F "text returned:|," '{print $3}')
################################################################################################
###Password confirmation tool
if [ "${jamfpass1}" == "${jamfpass2}" ]; then
logger "${message} ${currentuser} Passwords matched. So we can move on"

###Need to make a BigSur VS catalina vserion
if [[ $(sw_vers -buildVersion) > "20A" ]]; then
logger "${message} ${currentuser} is using a OS greater than Catalina Running BigSur Method"
bsdeviceidraw=$(curl -H "accept: application/xml" -ku ${jamfuser}:${jamfpass1} ${jamfurl}/JSSResource/mobiledevices | xpath -e '//mobile_device/id' 2>&1 | awk -F'<id>|</id>' '{print $2}')
for bsid in ${bsdeviceidraw};do
bsdevicename=$(curl -H "Accept: application/xml" -sku ${jamfuser}:${jamfpass1} ${jamfurl}/JSSResource/mobiledevices/id/${bsid} -X GET | xmllint --format - | xpath -e '//mobile_device/general/device_name' | awk -F '<device_name>|</device_name>' '{print $2}')
logger "${message} Found ${bsdevicename} for ${bsid}"
###Lets post it
curl -H "Accept: application/xml" -sku ${jamfuser}:${jamfpass1} ${jamfurl}/JSSResource/mobiledevicecommands/command/DeviceName/${bsdevicename}/id/${bsid} -X POST
logger "${message} Posting and sending rename/enforce name to device id ${bsid} with ${bsdevicename}"
done
logger "${message} have cycled through all ids. exiting now."
/usr/bin/osascript -e "display dialog \"Script has finished running, please check your devices \" with title \"Script complete\" buttons {\"Cancel\",\"Go\"} default button {\"Go\"}"


######RUNNING CATALINA
#else line 41
else 
logger "${message} ${currentuser} Using Catalina or older"	
deviceidraw=$(curl -H "accept: application/xml" -ku ${jamfuser}:${jamfpass1} ${jamfurl}/JSSResource/mobiledevices | xpath -e '//mobile_device/id' 2>&1 | awk -F'<id>|</id>' '{print $2}')
for bsid1 in ${deviceidraw};do
bsdevicename=$(curl -H "Accept: application/xml" -sku ${jamfuser}:${jamfpass1} ${jamfurl}/JSSResource/mobiledevices/id/${bsid1} -X GET | xmllint --format - | xpath -e '//mobile_device/general/device_name' | awk -F '<device_name>|</device_name>' '{print $2}')
logger "${message} Found ${devicename} for ${bsid1}"
###Lets post it
curl -H "Accept: application/xml" -sku ${jamfuser}:${jamfpass1} ${jamfurl}/JSSResource/mobiledevicecommands/command/DeviceName/${devicename}/id/${bsid1} -X POST
logger "${message} Posting and sending rename/enforce name to device id ${bsid1} with ${devicename}"
done
logger "${message} have cycled through all ids. exiting now."
/usr/bin/osascript -e "display dialog \"Script has finished running, please check your devices \" with title \"Script complete\" buttons {\"Cancel\",\"Go\"} default button {\"Go\"}"

###fi line 41
fi
###Line 37 else
else
logger "${message} ${currentuser} Passwords mismatched exiting and messaging user"
/usr/bin/osascript -e "display dialog \"Bad password. Your passwords did not match. You will need to re-run the script\" with title \"Password mismatch!\" buttons {\"Cancel\",\"Go\"} default button {\"Go\"}"
exit 0
###
#fi line 37
fi
#line 12 else
else
logger "${message} user opted to exit"
exit 0
###
#Fi line 12
fi
