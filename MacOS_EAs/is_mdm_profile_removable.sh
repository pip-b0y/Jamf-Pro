#!/bin/bash
#Detects if the profile can be removed or not based off its currently assigned pre-stage. Results on the device can be different if the device was assigned to a different pre-stage. Keep this in mind
#As is no warrenty.
status=$(profiles -e | grep "IsMDMUnremovable" | awk '{print $3}' | tr -d ';')
if [[ ${status} = '1' ]]; then
	echo "<result>NotRemovable</result>"
else
	if [[ ${status} = '0' ]]; then
		echo "<result>Removable</result>"
	else
		echo "<result>No Prestage detected</result>"
	fi
fi
