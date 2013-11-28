#!/bin/bash

# Load configs:
source install-mq.cfg
source create-qm.cfg

# Load function definitions:
source lib/try-run.sh
source lib/notices.sh

echo $MQ_BIN

# Get queue managers list:
queueManagers=$(cd $MQSC_CONFIG_FILES && ls -1 *.mqsc | sed -e 's/\.[a-zA-Z]*$//')

# For each MQSC file, create queue manager and import its configuration:
for qm in $queueManagers
do
	showNotice "Creating queue manager: $qm..."
	# Check if queue manager exists:
	qmExists=`sudo -u mqm -H sh -c "${MQ_BIN}dspmq | grep $qm"`
	if [ -n "$qmExists" ]
	then
		showWarning "Queue manager $qm already exists. Skipping."
		continue
	fi

	# Create queue manager as mqm user:
	sudo -u mqm -H sh -c "${MQ_BIN}crtmqm -lf 16384 -lp 20 -ls 50 -u SYSTEM.DEAD.LETTER.QUEUE $qm"
	# Start queue manager:
	sudo -u mqm -H sh -c "${MQ_BIN}strmqm $qm"
	# Import queue manager's config:
	sudo -u mqm -H sh -c "${MQ_BIN}runmqsc $qm < ${MQSC_CONFIG_FILES}${qm}.mqsc > ${MQSC_CONFIG_FILES}${qm}.out"
	# Start listener:
	sudo -u mqm -H sh -c "${MQ_BIN}runmqsc $qm" <<< "START LISTENER($qm)"
done
