#!/bin/bash
set -e

#Task Variables
domain=${bamboo.SMB_USER_DOMAIN}
destionDir=${bamboo.build.working.directory}/output

echo -e "user=${bamboo.SMB_USER_ID}\npass=${bamboo.SMB_PASSWORD}" > ~/.smbcredentials
pushd $destionDir/geoipdata

#Copying GeoIP data

source ~/.smbcredentials
smbget smb://contentfs.common.jagex.network/libscontent_v4/RC/geoip/run --recursive --user "$domain\\$user%$pass" -d 3

#Copying PacK data
smbget smb://contentfs.common.jagex.network/libscontent_v4/RC/words/pack/server.words.js5  --user "$domain\\$user%$pass" -d 3

#Echo-ing copied files
ls -ltr

#Removing cred files
rm ~/.smbcredentials