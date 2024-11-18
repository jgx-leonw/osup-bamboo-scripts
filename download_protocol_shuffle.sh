#!/bin/bash
set -e

# Task Variables
domain=${bamboo.SMB_USER_DOMAIN}
destionDir=${bamboo.build.working.directory}/output

echo -e "user=${bamboo.SMB_USER_ID}\npass=${bamboo.SMB_PASSWORD}" > ~/.smbcredentials
pushd $destionDir/protocolshuffle


# Ensure branch variable is set
if [ -z "$PROTOCOL_SHUFFLE_VERSION" ]; then
  echo "Error: protocol shuffle version is not set."
  exit 1
fi

# Define the network location and destination directory
PROTOCOL_SHUFFLE_SMB_URL="smb://artstore.office.jagex.com/oldscape-artifacts/clientprotshuffle/$PROTOCOL_SHUFFLE_VERSION"
DESTINATION_DIR="${bamboo.build.working.directory}/gameworld/protocolShuffle"

# Copying protocol shuffling data
source ~/.smbcredentials
smbget $PROTOCOL_SHUFFLE_SMB_URL --recursive --user "$domain\\$user%$pass" -d 3

#Echo-ing copied files
ls -ltr

#Removing cred files
rm ~/.smbcredentials