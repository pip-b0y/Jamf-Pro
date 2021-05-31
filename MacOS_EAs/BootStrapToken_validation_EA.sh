#!/bin/bash
#####Note
#You must supply the creds for an account with the secure token or this will fail out. Best to have the password passed in another way but will work on this at a later date.
#bootStrap Token Allowed
#Boot Strap Repair Script https://github.com/pip-b0y/MacOS/blob/master/helpers/boot_strap_token_repair.sh
#Need to have secure token user and pass
secure_token_user='SecureTokenUserHere'
secure_token_pass='securePasswordHere'
good_token="profiles: Bootstrap Token validated."
token_status=$(/usr/bin/sudo /usr/bin/profiles validate -type bootstraptoken -user=${secure_token_user} -password=${secure_token_pass} | grep "profiles: Bootstrap Token validated.")

###EA####
if [ "${token_status}" == "profiles: Bootstrap Token validated."  ]; then
	echo "<result>BootStrap is Good</result>"
else
	echo "<result>BootStrap is bad</result>"
fi
