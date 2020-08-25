#!/bin/bash

#Create By: pip-b0y
#Name: VPP-Global-Off
#Version: 1.2
#UseCase - This script is intended to turn off VPP Globally for Device deployments. This script does not impact end devices. 
#Its intended usage is for VPP Legacy token migrations to ASM or ABM. Given Some Orgs have Hundereds of applications and or 
#dont have the time to turn them all off, Yes it can be done via the database just as easy. But, going via the API ensures 
#we are not doing anything wrong


#Welcome Message
echo "Welcome to the VPP Changer Version:1.2"
echo "Please run this with caution"
read -n 1 -s -p "Press any key to start"
clear

#Varibles 
read -p "What is your Jamf URL? (with https and port) : " jssurl
read -p "what is your Jamf User Name: " apiuser
read -s -p "what is your password: " apipassword
clear

#warning message
echo "This script will update the VPP token that an Application in the mobile device application catalog is currently using. Please as with all scripts that have write access, use caution and do a test run first"
read -n 1 -s -p "Shall we procceed? Press any key to begin close Terminal to exit. "

#Get the VPP token current:
vpp_token_id=$(curl )

#Create the work area
mkdir /Users/Shared/MD-VPP-Update
mkdir /Users/Shared/MD-VPP-Update/o-data


#Script
app_id=$(curl -H "Accept: application/xml" -sku $apiuser:$apipassword $jssurl/JSSResource/mobiledeviceapplications | xpath '//mobile_device_application/id' 2>&1 | awk -F'<id>|</id>' '{print $2}')
for id in $app_id;do
	#backing Up the Apps Incase of roll back
backup=$(curl -H "Accept: application/xml" -sku $apiuser:$apipassword $jssurl/JSSResource/mobiledeviceapplications/id/$id -X GET | xmllint --format - > /Users/Shared/MD-VPP-Update/o-data/$id.xml)

		#Turn OFF
	curl -H "Accept: application/xml" -sku $apiuser:$apipassword $jssurl/JSSResource/mobiledeviceapplications/id/$id -X PUT -H "Content-Type: application/xml" -d "<mobile_device_application><vpp><assign_vpp_device_based_licenses>false</assign_vpp_device_based_licenses><vpp_admin_account_id>-1</vpp_admin_account_id></vpp></mobile_device_application>"

done
echo "Starting the MacOS Apps Now"
mac_app_id_raw=$(curl -H "Accept: application/xml" -sku $apiuser:$apipassword $jssurl/JSSResource/macapplications | xpath '//mac_application/id' 2>&1 | awk -F'<id>|</id>' '{print $2}')
for mac_app_id in $mac_app_id_raw;do
	backup2=$(curl -H "Accept: application/xml" -sku $apiuser:$apipassword $jssurl/JSSResource/macapplications/id/$mac_app_id -X GET | xmllint --format - > /Users/Shared/MD-VPP-Update/o-data/$mac_app_id-mac.xml)
	#Turnoff
	curl -H "Accept: application/xml" -sku $apiuser:$apipassword $jssurl/JSSResource/macapplications/id/$mac_app_id -X PUT -H "Content-Type: application/xml" -d "<mac_application><vpp><assign_vpp_device_based_licenses>false</assign_vpp_device_based_licenses><vpp_admin_account_id>-1</vpp_admin_account_id></vpp></mac_application>"
done
echo "We made a back up incase saved in /Users/Shared/MD-VPP-Update/o-data"