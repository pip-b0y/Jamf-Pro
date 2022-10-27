#!/bin/bash
#As is. You may need to declare other browsers. In MacOS default browser is seen as the com.vendor.browser
user=$(printf '%s\n' "${SUDO_USER:-$USER}")
userhome=$(eval echo "~${user}")
url="" #add URL HERE
#evaluate browser
defaultbrowser=$(defaults read ${userhome}/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure | awk -F'"' '/http;/{print window[(NR)-1]}{window[NR]=$2}')

if [ "$defaultbrowser" == "com.google.chome" ];then
	echo "Chrome is default"
open -an "/Applications/Google Chrome.app" --args "${url}"
else
open "/Applications/Safari" "${url}"

fi
