#!/bin/bash
#Cleans current company portal / jamf add objects for the user of the machine. Company portal will install again for the latest version. If you dont want it to install comment out line 65. 

currentuser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#function App
companyportal ()
{
	curl -k -L https://go.microsoft.com/fwlink/?linkid=862280 --output /Users/Shared/intune.pkg
	cd /Users/Shared
	sudo installer -pkg /Users/Shared/intune.pkg -target /
	
	#clean up 
	sudo rm -rf /Users/Shared/intune.pkg
}
####
#SCRIPT START###
killall 'JAMF'
echo "quit JAMF"
killall 'Company Portal' 
echo "quit Company Portal"
echo "Remove Company Portal"

#Remove all parts of company portal
rm -r -rf '/Users/${currentuser}/Applications/Company Portal.app/'
rm -rf '/Users/${currentuser}/Library/Application Support/com.microsoft.CompanyPortal.usercontext.info'
rm -rf '/Users/${currentuser}/Library/Application Support/com.jamfsoftware.selfservice.mac'
rm -r '/Users/${currentuser}/Library/Saved Application State/com.jamfsoftware.selfservice.mac.savedState' 
rm -r '/Users/${currentuser}/Library/Saved Application State/com.microsoft.CompanyPortal.savedState' 
rm -r '/Users/${currentuser}/Library/Preferences/com.microsoft.CompanyPortal.plist'
rm -r '/Users/${currentuser}/Library/Preferences/com.jamfsoftware.management.jamfAAD.plist' 
rm -r '/Users/${currentuser}/Library/Cookies/com.microsoft.CompanyPortal.binarycookies' 
rm -r '/Users/${currentuser}/Library/Cookes/com.jamf.management.jamfAAD.binarycookies'

echo "Remove keychain password items local key chain"
#Clean Items left by Company Portal
/usr/bin/sudo -iu ${currentuser} /usr/bin/security delete-generic-password -l 'com.jamf.management.jamfAAD' keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db"

/usr/bin/sudo -iu ${currentuser} /usr/bin/security delete-generic-password -l 'com.microsoft.CompanyPortal' keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db"

/usr/bin/sudo -iu ${currentuser} /usr/bin/security delete-generic-password -l 'com.microsoft.CompanyPortal.HockeySDK' keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db"

/usr/bin/sudo -iu ${currentuser} /usr/bin/security delete-generic-password -l 'enterpriseregistration.windows.net' keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db"

/usr/bin/sudo -iu ${currentuser} /usr/bin/security delete-generic-password -l 'https://device.login.microsoftonline.com' keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db"

/usr/bin/sudo -iu ${currentuser} /usr/bin/security delete-generic-password -l 'https://device.login.microsoftonline.com/' keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db"

/usr/bin/sudo -iu ${currentuser} /usr/bin/security delete-generic-password -l 'https://enterpriseregistration.windows.net' keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db"

/usr/bin/sudo -iu ${currentuser} /usr/bin/security delete-generic-password -l 'https://enterpriseregistration.windows.net/' keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db"

/usr/bin/sudo -iu ${currentuser} /usr/bin/security delete-generic-password -a 'com.microsoft.workplacejoin.thumbprint' keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db" 

/usr/bin/sudo -iu ${currentuser} /usr/bin/security delete-generic-password -a 'com.microsoft.workplacejoin.registeredUserPrincipalName' keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db" 

#Remove Extra Certificate
removecert=$(/usr/bin/sudo -iu ${currentuser} /usr/bin/security find-certificate keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db" -a -Z | grep -B 9 "MS-ORGANIZATION-ACCESS" | grep "SHA-1" | awk '{print $3}')

echo ${removecert}
/usr/bin/sudo -iu ${currentuser} /usr/bin/security delete-identity -Z ${removecert} keychain "/Users/${currentuser}/Library/Keychains/login.keychain-db"

#Clean JamfAAD incase I missed something
/usr/bin/sudo -iu ${currentuser} "/Library/Application\ Support/JAMF/Jamf.app/Contents/MacOS/JamfAAD.app/Contents/MacOS/JamfAAD" clean

#CompanyPortal Re-install

/usr/bin/sudo companyportal
exit 0
