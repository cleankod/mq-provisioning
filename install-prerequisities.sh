#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "notice: Updating apt-get"
apt-get -q -y update

# Install MC if it does not exists:
if [ -z $(command -v mc) ]
then
    echo "notice: Installing MC"
    apt-get -q -y install mc
fi

# Install RPM if it does not exists:
if [ -z $(command -v rpm) ]
then
    echo "notice: Installing RPM"
    apt-get -q -y install rpm
fi