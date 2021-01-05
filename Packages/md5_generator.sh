#!/bin/bash
#checks chunks
#Useage
#ChunkSize = 10485760 this is a Apple Requirement to break a package up into 10mb chunks.
#Script start
chunksize="10485760"
read -p "What is the path to the file: " filepath #this is the path to the file to generate the checksum
filebytes=$(stat -f "%z" "${filepath}")
nublocks=$((filebytes / chunksize))
[[ $((nublocks * ${chunksize})) -lt ${filebytes} ]] && : $((nublocks++))
blockno=0
while [[  ${blockno} -lt ${nublocks} ]]
do
	md5sum=$(dd bs=${chunksize} count=1 skip=${blockno} if=${filepath} 2>/dev/null | md5)
echo "$blockno $md5sum"
: $((blockno++))
done
