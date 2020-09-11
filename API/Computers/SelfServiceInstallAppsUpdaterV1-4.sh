#!/bin/bash
#We will encrypt the Jamf UserName and Password. 
#For Added Security can encrypt the Jamf URL as well. But there is no point in doing that.
#Version 1.4
#Improvements:1. 
#While Plist buddy is great - it does not work too well in changing the apps around moving to defaults read and write. Easier to manage.
#Notice there is a few different issues in the orginal script, like there is no clean up of the old.appname.app files that get left over. Adding in a clean up function to remove them.
#Have had to add a recon between each app update because of the nature that the script works to change the value of the install button in self service from Open or update to Install. 
#Added OSA script to 1 - warn the users that apps are going to update. and to inform the user that Self service will open and close. 
#Fixed up issue that was picking up other applications as VPP Apps
#Fixed issue in the API Calls made
###End of improvements.
#This script is just for apps that are Auto install. Self Service installed applications are commented out at this stage as it is not working. 
#the api user just needs read rights to the macapplications and that is it. You need to hard code your Jamf URL
#######################PREWORK################
#Note you can send the user name as plain text if you want it is easy to swap. How ever you can opp to encrypt it. 
#In Terminal on a MACOS device Paste the Following and remove the double ##:
######STARTPASTE###
##function GenerateEncryptedString() {
##Usage ~$ GenerateEncryptedString "String"
##local STRING="${1}"
##local SALT=$(openssl rand -hex 8)
##local K=$(openssl rand -hex 12)
##local ENCRYPTED=$(echo "${STRING}" | openssl enc -aes256 -a -A -S "${SALT}" -k "${K}")
##echo "Encrypted String Vaule 4 or 7: ${ENCRYPTED}"
##echo "Salt Becomes 5 or 8 : ${SALT} | Passphrase becomes 6 or 9: ${K}"
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
#1.3 version Change# IMPORTANT.
#because there is OSAScript that is targeting UI Objects  you will need to update the OSAScript to reflect the differing name.This will be dependant on the Branding you use in Self Service. It uses the main header object.
#tell application "System Events" to tell process "Self Service" to tell button "Install" of sheet 1 of window "Self service header here" to perform action "AXPress"
#currently set up to cater for a Out of the box unbranded Jamf Pro set up

#OtherVaribles
jamfurl="" #Hard Code Your JamfURL here
logpath="/tmp/updateapps.log"
logdate=$(date +"%Y-%m-%d %H:%M:%S")
###
#DecryptingActionhere#normally we can use the $4,$5 to add in the encrypted string for our purpose we will hard code them in here for testing
apiuser=$(echo "$4" | /usr/bin/openssl enc -aes256 -d -a -A -S "$5" -k "$6")
apipass=$(echo "$7" | /usr/bin/openssl enc -aes256 -d -a -A -S "$8" -k "$9")
###
#User Details.
currentuser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
###
#Build the list to cycle through
app_list_write=$(ls /Applications/ | grep ".*\.app" >> /tmp/macOSapp.tmp)
app_list_read="/tmp/macOSapp.tmp"
app_id_list="/tmp/app_id_list.tmp"
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
	if [ -d "/Applications/$app_name/Contents/_MASReceipt" ]
	then
#SCRIPT FOR WHEN IT IS VPP START
		echo "$logdate [VPP APP] $app_name detected. Running update check." >> $logpath
		currentversion_raw=$(defaults read /Applications/"$app_name"/Contents/Info.plist "CFBundleShortVersionString")
		echo "$logdate [VPP APP] $app_name is $currentversion_raw" >> $logpath
		app_name_api=$(echo "$app_name" | sed 's/ /%20/g' | sed 's/.app//g')
		echo "$logdate [api call to Jamf] We made the name nice for the api. $app_name_api" >> $logpath
		app_data_raw=$(curl -H "accept:application/xml" -sku "$apiuser:$apipass" "$jamfurl/JSSResource/macapplications/name/$app_name_api" | xmllint --format - > /tmp/$app_name_api.xml)
		
		#Removed in version 1.1. It is better to have the data on the device instead to reference. Less curls.
		#jamfversion_raw=$(curl -H "accept:application/xml" -sku "$apiuser:$apipass" "$jamfurl/JSSResource/macapplications/name/$app_name_api" | xpath '//mac_application/general/version' 2>&1 | awk -F'<version>|</version>' '{print $2}')
		jamfversion_raw=$(cat /tmp/$app_name_api.xml | xpath '//mac_application/general/version' 2>&1 | awk -F '<version>|</version>' '{print $2}')
		application_id=$(cat /tmp/$app_name_api.xml | xpath '//mac_application/general/id' 2>&1 | awk -F '<id>|</id>' '{print $2}')
		echo "$logdate [Jamf VPP version] Jamf has returned $app_name as version $jamfversion_raw" >> $logpath
		echo "$application_id" >> app_id_list.tmp	

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
defaults write /Applications/old."$app_name" "CFBundleShortVersionString" -string "removed"
defaults write /Applications/old."$app_name" "CFBundleShortVersionString" -string "removed" #added twice as some apps have it twice for some reason
echo "$logdate [App Update Utility] $app_name has been moved. This will allow the update. It moved to /Applications/old.$app_name" >> $logpath
echo "$logdate [App Update Utility] A recon will be reqired to get the app to install again " >> $logpath
jamf recon &>/dev/null &disown
		echo "$logdate [App Udate Utility] Pre flight has finished we build a list" >> $logpath
		fi
#SCRIPT FOR WHEN IT IS VPP END
		else
			#For when a app is not VPP Start
			echo "$logdate [Not VPP APP] $app_name detected. Please consider updating via the Mac App Store" >> $logpath 
			results="$app_name is not vpp installed. We will ignore it. Consider updating via the Mac App Store"
			#For When a app is not VPP stop
			fi
			done < $app_list_read
#####Re-install mechanic#####
#Fix app list. It catches other apps for some reason
cat $app_id_list | sed '/^[[:space:]]*$/d' > /tmp/to-be-installed.file
app_id_list="/tmp/to-be-installed.file"
while read -r app_to_update_id;do 
echo "$logdate [App Update Utility] checking to install via Self Service. running open jamfselfserivce://content?entity=app&id=$app_to_update_id&action=view" >> $logpath
#New In V1.3
osascript <<EOD
activate application "Self Service"
tell application "System Events" to keystroke "r" using command down
EOD
sleep 5
open "jamfselfservice://content?entity=app&id=$app_to_update_id&action=view"	
#new in v1.3
osascript <<EOD
tell application "System Events" to tell process "Self Service" to tell button "Install" of sheet 1 of window "Self Service" to perform action "AXPress"
tell application "System Events" to tell process "Self Service" to tell button "Close" of sheet 1 of window "Self Service" to perform action "AXPress"
EOD
	done < $app_id_list

#Starting clean up
echo "$logdate [Clean up] cleaning the old applications" >> $logpath
rm -rf /Applications/old.*.app
rm -rf /Applications/old.*.app.plist
rm /tmp/macOSapp.tmp
rm /tmp/app_id_list.tmp
rm /tmp/to-be-installed.file
rm /tmp/*.xml
sudo jamf recon
echo "$logdate [Ran a recon]" >> $logpath
echo "$logdate [script end] The program has finished." >> $logpath