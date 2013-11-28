tryRun() {
	$*
	if [ $? -ne 0 ]
	then
		echo "$* failed."
		exit 1
	fi
}