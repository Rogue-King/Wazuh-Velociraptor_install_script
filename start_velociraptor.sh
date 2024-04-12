#!/bin/bash

# List of IP addresses
#echo "Please enter ip space: "
#echo "Ex: 192.168.8."
#read IP_SPACE

IP_SPACE="192.168.8."

#echo "Please enter target IP Addresses:"
#read -a IP_ADDRESS

IP_ADDRESS=("51" "52" "53" "54" "55" "100" "101" "102" "103" "202" "205")

# Define the SSH command to run
SSH_COMMAND="ssh root@"

#echo "Please enter path of your .deb for your clients:"
#read DEB_FILE
DEB_FILE="velociraptor_client_0.7.1.2_amd64.deb"

SCP_DEB="scp $DEB_FILE root@"
SCP_DEB_TARGET="/root/"

SCP_SERVICE="scp velociraptor.service root@"
SCP_SERVICE_TARGET=":/lib/systemd/system/velociraptor.service"
# Define the number of iterations

index=0
# Loop through the list of IP addresses
while [ $index -lt ${#IP_ADDRESS[@]} ]; do
	IP="${IP_ADDRESS[$index]}"
	echo "Connecting to $IP..."

	# Run the commands

	#scp the deb file to target
	$SCP_DEB$IP_SPACE$IP ':' $SCP_DEB_TARGET
	#$SCP_DEB$IP_SPACE$IP ':' $SCP_DEB_TARGET$DEB_FILE # for when deb file is not in /root/

	#send ssh command to run the binary
	$SSH_COMMAND$IP_SPACE$IP 'dpkg -i' $SCP_DEB_TARGET$DEB_FILE

	#send the service file for systemd to targets to run velociraptor_client
	$SCP_SERVICE$IP_SPACE$IP$SCP_SERVICE_TARGET

	#enable and run the service file on targets
	$SSH_COMMAND$IP_SPACE$IP 'systemctl daemon-reload'
	timeout 10s $SSH_COMMAND$IP_SPACE$IP 'systemctl enable --now velociraptor'
	#$SSH_COMMAND$IP_SPACE$IP 'systemctl status velociraptor'

	echo "-----------------------------------"
	((index++))
done
