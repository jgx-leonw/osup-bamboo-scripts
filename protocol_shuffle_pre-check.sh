#!/bin/bash

#Pre-Check task creates required output folder(s)
echo "Creating output directories"
if [ ! -d ${bamboo.build.working.directory}/output ]; then
    mkdir ${bamboo.build.working.directory}/output
fi

if [ ! -d ${bamboo.build.working.directory}/output/protocolshuffle ]; then
    mkdir ${bamboo.build.working.directory}/output/protocolshuffle
    else
    echo "removing old data"
    pushd ${bamboo.build.working.directory}/output/protocolshuffle
    rm -rf *
fi

#Install SMBClient to access shared files
echo "Installing smbclient"
apt-get update && \
    apt-get install -y smbclient