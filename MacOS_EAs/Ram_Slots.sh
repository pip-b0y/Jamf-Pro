#!/bin/bash

#RAM Information Gather v1
#Gets the Ram in each Ram slot and its speed (read from the chips)
#RamFile="/Library/Application\ Support/JAMF/ram.file"
tempfile="/tmp/temp.xml"
workingspace="/tmp/work.xml"
RamFile="/Users/Shared/ram.xml"
#Pre Flight
if test -f "${RamFile}"; then
	echo "File is there lets read the file"
	
	else
		#create for the first run
		system_profiler SPMemoryDataType > "${tempfile}"
		#Lets breakdown the file
		cat "${tempfile}" | grep "BANK" > "${workingspace}"
		while read -r bank;do
			#echo "${bank}" | grep "BANK" >> "${RamFile}"
			Rsize=$(cat "${tempfile}" | grep -A 4 "${bank}" | grep "Size")
			Rspeed=$(cat "${tempfile}" | grep -A 4 "${bank}" | grep "Speed")
			#Create the file
			echo ${bank} >> ${RamFile}
			echo ${Rsize} >> ${RamFile}
			echo ${Rspeed} >> ${RamFile}
			done < "${workingspace}"
		fi
		#quickCleanUp
		rm "${workingspace}"
		rm "${tempfile}"
		
		#Jamf Stuff
		finalresult=$(cat "${RamFile}")
		#send to JAMF
		echo "<result>${finalresult}</result>"
