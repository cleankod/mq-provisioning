#!/bin/bash

# Load configs:
source install-mq.cfg

source lib/try-run.sh
source lib/notices.sh

# Selects proper suffix for package file names, based on the long mode (32 or 64 bit):
SetLongMode()
{
	showNotice "MODE $LONG_MODE"
	case "$LONG_MODE" in
		32) installMode='i386' ;;
		64) installMode='x86_64' ;;
		*)
			showError "Unknown mode [${LONG_MODE}]"
			exit 1
			;;
	esac
	
}

# Function installs the MQ:
InstallMQ()
{
    cd /install/mq
	
	licenseFile="./mqlicense.sh"
	
	# Check if the file is executable:
	if [[ ! -x "$licenseFile" ]]
	then
		showError "File '$licenseFile' is not executable or not found."
		exit 1
	fi
	
    tryRun "$licenseFile" -accept
    rpm -ivh --nodeps --force-debian MQSeriesRuntime-"$MQ_VERSION"."$installMode".rpm
    rpm -ivh --nodeps --force-debian MQSeriesServer-"$MQ_VERSION"."$installMode".rpm
    rpm -ivh --nodeps --force-debian MQSeriesSDK-"$MQ_VERSION"."$installMode".rpm
    rpm -ivh --nodeps --force-debian MQSeriesClient-"$MQ_VERSION"."$installMode".rpm
    rpm -ivh --nodeps --force-debian MQSeriesJava-"$MQ_VERSION"."$installMode".rpm
    rpm -ivh --nodeps --force-debian MQSeriesSamples-"$MQ_VERSION"."$installMode".rpm
    rpm -ivh --nodeps --force-debian MQSeriesMan-"$MQ_VERSION"."$installMode".rpm
    rpm -ivh --nodeps --force-debian MQSeriesGSKit-"$MQ_VERSION"."$installMode".rpm
    chown -R mqm:mqm /opt/mqm
    chown -R mqm:mqm /var/mqm
    cd /install/mq/autostart
    rpm -ivh --nodeps --force-debian MSL1-1.0.1-1.noarch.rpm
    mv /etc/init.d/ibm.com-WebSphere_MQ /etc/init.d/mq
	update-rc.d mq defaults
    cd
}

# Sets mqm user environment:
SetMqmEnv()
{
	# Set MQ environment config:
	echo ". /opt/mqm/bin/setmqenv -s" > /var/mqm/.bashrc && chmod +x /var/mqm/.bashrc
}

# Changes the mqm user shell:
ChangeMqmShell()
{
	chsh -s /bin/bash mqm
}

if [ -z $(getent passwd mqm) ]
then
    showNotice "Installing MQ..."
	SetLongMode
    InstallMQ
    SetMqmEnv
    ChangeMqmShell
else
    showNotice "MQ already installed"
fi
