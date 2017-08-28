#!/bin/bash

# TO DO
# by priority
# setting network
# parameters - script behavior with and without ()
# cpu
# VIDEO ERR WARNING SHOWING UP
# video etc.
#######################################
#######################################
#
#	interfaces probably fucked up
#
#
#######################################
#######################################
# DONE
# create machine
# create disk
# mount .iso
#

# variables
# negative values - if yes read input from user otherwise it\'s script parameter
RE='^[0-9]+$'
VB="VBoxManage"
NETWORK_CARD_TYPE=("NAT" "NAT Network" "Bridged" "Inner Net" "Isolated Network")
NETWORK_CARDS_COUNT=-1
NETWORK_INTERFACES=($(netstat -i | awk '{if ( NR > 2 ) print $1}'))
CABLE_CONNECTED="off"
CARDS_COUNT=-1
CPU_COUNT=-1
CPU_EXECUTION_CAP=-100
MEMORY_SIZE=-1

###############################
#####			  							#####
#####      FUNCTIONS      #####
#####                     #####
###############################
function DEBUG(){
	echo $1
}

function FUNCTION_HELP(){
	echo -n "Simple bash script for creating VitrualMachines with VirtualBox CLI:
	Usage: vmMake.sh [option]...
	-h --help\t show this info
	"
	exit 0
}

function FUNCTION_CABLE_CONNECED(){
	while true; do
		read -p "Cable connected? (on/off): " CABLE_CONNECTED
			case "$CABLE_CONNECTED" in
				"on") break ;;
				"off") break ;;
				*) read -n 1 -s -r -p "Your input is not corrected!\nPress any key to continue"
			esac
	done
}

###############################
#####			  	WIP					#####
#####      PARAMETRS      #####
#####                     #####
###############################

while [[ $# -ge 1 ]]
do
	option="$1"
	case ${option} in
		-h|--help)
			FUNCTION_HELP
			shift
			;;
		-m|--memory)
			shift
			if ! [[ $1 =~ $RE ]]; then
				echo "MEMORY_SIZE wrong value!\nExiting"
				exit 1
			MEMORY_SIZE=$1
			shift
			;;
		-c|--cpu-count)
			shift
			if ! [[ $1 =~ $RE ]]; then
				echo "CPU_COUNT wrong value!\nExiting"
				exit 1
			CPU_COUNT=$1
			;;
		-C|--cpu-execution-cap)
			shift
			if ! [[ $1 =~ $RE ]]; then
				echo "CPU_EXECUTION_CAP wrong value\nExiting"
				exit 1
			CPU_EXECUTION_CAP=$1
			;;
		-n|--network-cards-count)
			shift
			if ! [[ $1 =~ $RE ]]; then
				echo "NETWORK_CARDS_COUNT wrong value\nExiting"
				exit
	esac
done



###########################################################
##########	     		DEBUG TESTS HERE						###########
###########################################################

###########################################################


###############################
#####			  							#####
#####         MAIN        #####
#####                     #####
###############################
clear
printf  "Simple bash script to make VM with virtualbox cli.\n\n\n"
read -n 1 -s -p "Press any key to continue"
clear
read -p "Write how VM should name: " NAME


while true; do
	clear
	read -p "Write disk size (MB): " DISK_SIZE
	if ! [[ $DISK_SIZE =~ $RE ]] ; then
		read -n 1 -s -p "Size can contain only numbers!\nPress any key to continue"
		continue
	fi
	break
done

$VB createvm --name $NAME --register
$VB createhd --filename /home/$USER/VirtualBox\ VMs/$NAME/$NAME.vdi  --size $DISK_SIZE 2>/dev/null


# NOW USER INPUT
# LIST WIP
while true; do
	clear
	VBoxManage list ostypes | grep -A 1 ^ID: | sed -e '/--/d' -e 's/ \{1,\}/ /g' \
	-e 's/ /;/g'| awk '{if (NR % 2 == 1) printf $0"  "; else printf $0"\n"}' | column -t | sed 's/;/ /g'
	read -p "Write vm's OS type: " OSTYPE
	$VB modifyvm $NAME --ostype $OSTYPE
	if [ $# -ne 0 ] ; then
        	echo "Something went wrong!\nExiting :("
        	exit 1
	fi
	break
done

while true; do
	clear
	read -p "Write memory size (MB): " MEMORY_SIZE
	if ! [[ $MEMORY_SIZE =~ $RE ]] ; then
		read -n 1 -s -p "Size can contain only numbers!\nPress any key to continue"
		continue
	fi
	break
done

$VB modifyvm $NAME --memory $MEMORY_SIZE

# STORAGE CONTROLER FOR NOW WITHOUT SELECTION
$VB storagectl $NAME --name "IDE Controller" --add ide
$VB storageattach $NAME --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium /home/$USER/VirtualBox\ VMs/$NAME/$NAME.vdi

while true; do
	clear
	read -e -p "Write here path to your .iso drive wchich you want use to install: " ISO_PATH
	exist=$(ls $ISO_PATH)
	if [ $# -ne 0 ] ; then
		echo "File does not exists"
		read -n 1 -s -r -p "Press any key to continue"
		clear
	fi
	break
done
$VB storageattach $NAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $ISO_PATH
###############################
#####			  							#####
#####         CPU         #####
#####         GPU         #####
#####                     #####
###############################

$VB modifyvm $NAME



###############################
#####			  							#####
#####       NETWORK       #####
#####                     #####
###############################

# ONLY NAT WORKING NOW
# BRIDGE SOMETHING FUCKED UP
clear
while true; do
	read -p "Write how many network cards you want: " CARDS_COUNT
	if ! [[ $CARDS_COUNT =~ $RE ]] ; then
		read -n 1 -s -p "Only numbers are allowed!\nPress any key to continue"
		continue
	fi
	break
done
for (( i=0; i<$CARDS_COUNT; i++ )); do
	clear
	for ((j=0; j < 5; j++)); do
		echo "$(($j + 1)). ${NETWORK_CARD_TYPE[$j]}"
	done
	read -p "Write number which type of card it will be: " CARD_TYPE
	case "$CARD_TYPE" in
		1)
			FUNCTION_CABLE_CONNECED
			$VB modifyvm $NAME --nic$(($i+1)) nat --cableconnected$(($i+1)) $CABLE_CONNECTED
			;;
		2)
			;;
		3)
			while true; do
				clear
				for ((j=0; j < ${#NETWORK_INTERFACES[@]}; j++)); do
					printf "$(($j+1)). ${NETWORK_INTERFACES[$j]}\n"
				done
				read -p "Write number which interface wil bridge: " BRIDGE_ADAPTER
				if  ! [[ $BRIDGE_ADAPTER =~ $RE ]] || [ $BRIDGE_ADAPTER -lt 1 ] || \
					[ $BRIDGE_ADAPTER -gt ${#NETWORK_INTERFACES[@]} ]; then
					read -n 1 -s -p "You have written wrong values!\nPress any key to continue"
					continue
				fi
				break
			done
			FUNCTION_CABLE_CONNECED
			$VB modifyvm $NAME --nic$(($i+1)) bridged --bridgeadapter$(($i+1)) \
				$NETWORK_INTERFACES[$(($BRIDGE_ADAPTER-1))] --cableconnected$(($i+1)) $CABLE_CONNECTED
			;;
		4)
			;;
		5)
			;;
		*)
			read -n 1 -s -p "You have written wrong values!\nPress any key to continue"
	esac
done
read -p "Do you want to start machine?\nRemember to change boot order after installation!\n
	Write  y  if yes, anything else if no: " DECISION
case option in
	y)
		$VB startvm $NAME &
		;;
	*)
		clear
		exit 0
esac
