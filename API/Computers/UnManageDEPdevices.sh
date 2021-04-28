#!/bin/bash


###Vars
message="Device UnManage: [Info]"
workingpath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
currentuser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
######
scriptname="Send a remove MDM Profile Command to MacOS Devices"
buttonreturned=$(/usr/bin/osascript -e "display dialog \"By Running this Script it is assumed that you have done the following:
1 - ran sudo jamf removeframework. This can be done via a policy. It is best to do this via a static group policy because we can use that same static group to send the bulk un-manage to the devices in that static group. We will be using the group ID
2 - Device is DEP and still has its MDM profile present.
Please use caution and the script is as is.\" with title \"${scriptname}\" buttons {\"Go\",\"Feedback\", \"Cancel\"} default button {\"Go\"}")
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
groupidraw=$(/usr/bin/osascript -e "display dialog \"Computer Group ID can be obtained from the url when looking at the static group in jamf pro id=XX it is the XX that we are after. \" default answer \"1\" with title \"Static computer group ID\" buttons {\"Cancel\",\"submit\"} default button {\"submit\"}")
groupid=$(echo "${groupidraw}" | /usr/bin/awk -F "text returned:|," '{print $3}')
logger "${message} ${currentuser} entered the targeted ${groupid}"
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
	computeridraw=$(curl -ku ${jamfuser}:${jamfpass1} ${jamfurl}/JSSResource/computergroups/id/${groupid} | xmllint --format - | xpath -e '//computer_group/computers/computer/id' 2>&1 | awk -F'<id>|</id>' '{print $2}')

for computerid in ${computeridraw};do
logger "${message} ${currentuser} sending a removal command to ${computerid}"
curl -ku ${jamfuser}:${jamfpass1} ${jamfurl}/JSSResource/computercommands/command/UnmanageDevice/id/${computerid} -X POST
done
logger "${message} have cycled through all ids. exiting now."
/usr/bin/osascript -e "display dialog \"Script has finished running, please check your devices \" with title \"Script complete\" buttons {\"Cancel\",\"Go\"} default button {\"Go\"}"
######RUNNING CATALINA
else
logger "${message} ${currentuser} Using Catalina or older"	
	computeridraw1=$(curl -ku ${jamfuser}:${jamfpass1} ${jamfurl}/JSSResource/computergroups/id/${groupid} | xmllint --format - | xpath '//computer_group/computers/computer/id' 2>&1 | awk -F'<id>|</id>' '{print $2}')
for computerid1 in ${computeridraw1};do
logger "${message} ${currentuser} sending a removal command to ${computerid1}"
curl -ku ${jamfuser}:${jamfpass1} ${jamfurl}/JSSResource/computercommands/command/UnmanageDevice/id/${computerid1} -X POST
done
logger "${message} have cycled through all ids. exiting now."
/usr/bin/osascript -e "display dialog \"Script has finished running, please check your devices \" with title \"Script complete\" buttons {\"Cancel\",\"Go\"} default button {\"Go\"}"
fi
else
logger "${message} ${currentuser} Passwords mismatched exiting and messaging user"
/usr/bin/osascript -e "display dialog \"Bad password. Your passwords did not match. You will need to re-run the script\" with title \"Password mismatch!\" buttons {\"Cancel\",\"Go\"} default button {\"Go\"}"
exit 0
fi
else
###Shameless plug
if [ "${buttonresult}" = "Feedback" ]; then
open "https://github.com/pip-b0y"
else
				
logger "${message} user opted to exit"
exit 0
###
fi
fi
