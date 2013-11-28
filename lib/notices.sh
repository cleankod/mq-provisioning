showError() {
	echo -e "\e[00;31mERR: $1\e[00m"
}

showNotice() {
	echo -e "\e[00;34mNOTICE: $1\e[00m"
}

showWarning() {
	echo -e "\e[00;33mWARN: $1\e[00m"
}