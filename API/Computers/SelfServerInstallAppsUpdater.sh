#!/bin/bash
#We will encrypt the Jamf UserName and Password. 
#For Added Security can encrypt the Jamf URL as well. But there is no point in doing that.
#Version 1.2
#This script is just for apps that are Auto install. Self Service installed applications are commented out at this stage as it is not working. 
#the api user just needs read rights to the macapplications and that is it. You need to hard code your Jamf URL
#######################PREWORK################
#Note you can send the user name as plain text if you want it is easy to swap. How ever you can opp to encrypt it. 
#In Terminal on a MACOS device Paste the Following and remove the double ##:
######STARTPASTE###
##function GenerateEncryptedString() {
# Usage ~$ GenerateEncryptedString "String"
##	local STRING="${1}"
##	local SALT=$(openssl rand -hex 8)
##	local K=$(openssl rand -hex 12)
##	local ENCRYPTED=$(echo "${STRING}" | openssl enc -aes256 -a -A -S "${SALT}" -k "${K}")
##	echo "Encrypted String Vaule 4 or 7: ${ENCRYPTED}"
##	echo "Salt Becomes 5 or 8 : ${SALT} | Passphrase becomes 6 or 9: ${K}"
##}
######ENDPASTE###
#After Running this Plug in the responses to make this script work. 
#Jamf Varibles for EndPoint Client
#username
#apiuser_string="" #normally will be $4
#apiuser_salt="" #normally will be $5
#apiuser_pphrase="" #normally will be $6
###
#password
#apipass_string="" #normally will be $7
#apipass_salt="" #normally will be $8
#apipass_pphrase="" #normally will be $9
###


#OtherVaribles
jamfurl="" #Hard Code Your JamfURL here
logpath="/tmp/updateapps.log"
logdate=$(date +"%Y-%m-%d %H:%M:%S")
###
#DecryptingActionhere#normally we can use the $4,$5 to add in the encrypted string for our purpose we will hard code them in here for testing
apiuser=$(echo "$4" | /usr/bin/openssl enc -aes256 -d -a -A -S "$5" -k "$6")
apipass=$(echo "$7" | /usr/bin/openssl enc -aes256 -d -a -A -S "$8" -K "$9")
###
#User Details.
currentuser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
###
#Build the list to cycle through
app_list_write=$(ls /Applications/ | grep ".*\.app" >> /tmp/macOSapp.tmp)
app_list_read="/tmp/macOSapp.tmp"
###
#build the log
if [ -s $logpath ]
then
echo "$logdate [script start] log file was there. Kicking off script run" >> $logpath
else
touch $logpath
fi
###
#Script Start
while read -r app_name; do
	if [ -d /Applications/"$app_name"/Contents/_MASReceipt/ ]
	then
#SCRIPT FOR WHEN IT IS VPP START
		echo "$logdate [VPP APP] $app_name detected. Running update check." >> $logpath
		currentversion_raw=$(/usr/libexec/PlistBuddy -c 'print :CFBundleShortVersionString' /Applications/"$app_name"/Contents/Info.plist)
		echo "$logdate [VPP APP] $app_name is $currentversion_raw" >> $logpath
		app_name_api=$(echo "$app_name" | sed 's/ /%20/g')
		echo "$logdate [api call to Jamf] We made the name nice for the api. $app_name_api" >> $logpath
		app_data_raw=$(curl -H "accept:application/xml" -sku "$apiuser:$apipass" "$jamfurl/JSSResource/macapplications/name/$app_name_final" | xmllint --format - > /tmp/$app_name_final.xml)
		
		#Removed in version 1.1. It is better to have the data on the device instead to reference. Less curls.
		#jamfversion_raw=$(curl -H "accept:application/xml" -sku "$apiuser:$apipass" "$jamfurl/JSSResource/macapplications/name/$app_name_final" | xpath '//mac_application/general/version' 2>&1 | awk -F'<version>|</version>' '{print $2}')
		jamfversion_raw=$(cat /tmp/$app_name_final.xml | xpath '//mac_application/general/version' 2>&1 | awk -F '<version>|</version>' '{print $2}')
		application_id=$(cat /tmp/$app_name_final.xml | xpath '//mac_application/general/id' 2>&1 | awk -F '<id>|<id>' '{print $2}')
		echo "$logdate [Jamf VPP version] Jamf has returned $app_name as version $jamfversion_raw" >> $logpath		

#fix the numbers to compare
jamfversion=$(echo "$jamfversion_raw" | tr -d '.,')
currentversion=$(echo "$currentversion_raw" | tr -d '.,')
if [ $currentversion -ge $jamfversion ]; then
	echo "$logdate [Version Check] looks like the version is either the same or newer. No action needed for $app_name" >> $logpath
	else
		echo "$logdate [Version Check] looks like $app_name needs to update. Starting the actions." >> $logpath
#will build 2 versions 1 that will force kill the application, 2 that will prompt the user to press ok to start the update
app_kill=$(echo $app_name | sed 's/\.[^.]*$//')
pkill -x "$app_kill"
echo "$logdate [App Update utility] $app_name is updating. We are killing it now" >> $logpath
mv /Applications/"$app_name" /Applications/old."$app_name"
/usr/bin/sudo /usr/libexec/PlistBuddy -c 'delete :CFBundleShortVersionString' /Applications/old."$app_name"
echo "$logdate [App Update Utility] $app_name has been moved. This will allow the update. It moved to /Applications/old.$app_name" >> $logpath
echo "$logdate [App Update Utility] A recon will be reqired to get the app to install again If it is installed Automatically" >> $logpath	
echo "$logdate [App Update Utility] checking to install via Self Service. running open "jamfselfserivce://content?entity=app&id=$application_id&action=execute" this might fail" >> $logpath
open "jamfselfservice://content?entity=app&id=$application_id&action=execute"	
		fi
#SCRIPT FOR WHEN IT IS VPP END
		else
			#For when a app is not VPP Start
			echo "$logdate [Not VPP APP] $app_name detected. Please consider updating via the Mac App Store" >> $logpath 
			results="$app_name is not vpp installed. We will ignore it. Consider updating via the Mac App Store"
			#For When a app is not VPP stop
			fi
			done < $app_list_read
sudo jamf recon
echo "$logdate [Ran a recon]" >> $logpath
echo "$logdate [script end] The program has finished." >> $logpath
