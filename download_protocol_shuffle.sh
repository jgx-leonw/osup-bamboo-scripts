#!/bin/bash

# Ensure branch variable is set
if [ -z "$PROTOCOL_SHUFFLE_VERSION" ]; then
  echo "Error: protocol shuffle version is not set."
  exit 1
fi

# Define the network location and destination directory
PROTOCOL_SHUFFLE_DIR="\\\\artstore.office.jagex.com\\oldscape-artifacts\\clientprotshuffle\\$PROTOCOL_SHUFFLE_VERSION"
DESTINATION_DIR="${bamboo.build.working.directory}/gameworld/protocolShuffle"

# Create the destination directory if it doesn't exist
mkdir -p "$DESTINATION_DIR"

# Check if smbclient is installed, if not install it
if ! command -v smbclient &> /dev/null; then
  echo "smbclient could not be found, installing..."
  sudo apt-get update
  sudo apt-get install -y smbclient
fi

# Use smbclient to download the files from the network location
smbclient "$PROTOCOL_SHUFFLE_DIR" -c "prompt OFF; recurse ON; mget *" -U username%password -D "$DESTINATION_DIR"

# Check if the download was successful
if [ $? -eq 0 ]; then
  echo "Download completed successfully."
else
  echo "Error: Download failed."
  exit 1
fi