#!/bin/bash

jssurl='' #JSSURL
jssuser='' #JSS User name
jsspass='' #password
token_raw=$(printf "${jssuser}:${jsspass}" | iconv -t ISO-8859-1 | base64 -i -)
read -p 'serial number to lookup: ' serial_number
#Auth Token#
api_token=$(curl -X POST ${jssurl}/api/v1/auth/token -H "accept: application/json" -H "Authorization: Basic ${token_raw}" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj ["token"]')

pre_stage_list=$(curl -X GET ${jssurl}/api/v2/computer-prestages/scope  -H "accept: application/json" -H "Authorization: Bearer ${api_token}" > /tmp/raw_pre_stage.json)
if grep -q ${serial_number} /tmp/raw_pre_stage.json
then
	echo "serial assigned grabbing the pre-stage"
pre_stage_id_raw=$(cat /tmp/raw_pre_stage.json | grep "${serial_number}" | awk '{print $3}' | tr -d '"')
pre_stage_name=$(curl -X GET ${jssurl}/api/v2/computer-prestages/${pre_stage_id_raw} -H "accept: application/json" -H "Authorization: Bearer ${api_token}" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj ["displayName"]')

echo "${serial_number} is assigned to '${pre_stage_name}' which is ID ${pre_stage_id_raw}"
else 
	echo "${serial_number} not there. Not assigned"
fi
