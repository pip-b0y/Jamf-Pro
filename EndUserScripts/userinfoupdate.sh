#!/bin/bash

###Updates the users name on Jamf Record.
#enter in the information that you want end users to see as a messaging guide. It will do a recon to update the users information in the device record.
#As is

userhelp="" #Message to the user
title="" #Title of message box
userexample="" #Example to the user
currentuser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

enduserldap=$( /usr/bin/osascript -e "display dialog \"${userhelp}\" default answer \"${userexample}\" with title \"${title}\" buttons {\"Cancel\",\"submit\"} default button {\"submit\"}")

/usr/bin/sudo jamf recon -endUsername ${enduserldap}
