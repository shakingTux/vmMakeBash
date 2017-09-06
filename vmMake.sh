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
re='^[0-9]+$'
VB="VBoxManage"
network_card_type=("NAT" "NAT Network" "Bridged" "Inner Net" "Isolated Network")
network_cards_count=-1
network_interfaces=($(netstat -i | awk '{if ( NR > 2 ) print $1}'))
cable_connected="off"
cards_count=-1
cpu_count=-1
cpu_execution_cap=-100
memory_size=-1

###############################
#####			  							#####
#####      FUNCTIONS      #####
#####                     #####
###############################
function debug(){
	echo $1
}

function function_help(){
	echo -n "Simple bash script for creating VitrualMachines with VirtualBox CLI:
Usage: vmMake.sh [option]... [value]
-h --help			show this info
-m --memory			set ram amount
-c --cpu-count			number of CPU
-C --cpu-execution-cap		execution cup <0-100> (in %)
-n --network-cards-count	number of network cards
-N --name			name of the vm
"
	exit 0
}

function function_cable_connected(){
	while true; do
		read -p "Cable connected? (on/off): " cable_connected
			case "$cable_connected" in
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
			function_help
			shift
			;;
		-m|--memory)
			shift
			if ! [[ $1 =~ $re ]]; then
				echo "memory_size wrong value!\nExiting"
				exit 1
			fi
			memory_size=$1
			shift
			;;
		-c|--cpu-count)
			shift
			if ! [[ $1 =~ $re ]]; then
				echo "cpu_count wrong value!\nExiting"
				exit 1
			fi
			cpu_count=$1
			;;
		-C|--cpu-execution-cap)
			shift
			if ! [[ $1 =~ $re ]]; then
				echo "cpu_execution_cap wrong value\nExiting"
				exit 1
			fi
			cpu_execution_cap=$1
			;;
		-n|--network-cards-count)
			shift
			if ! [[ $1 =~ $re ]]; then
				echo "network_cards_count wrong value\nExiting"
				exit 1
			fi
			;;
		-N|--name)
			shift
			if [[ -z $1 ]];then
				echo "name is empty\nExiting\n"
				exit 1
			fi
			NAME=$1
			;;
	esac
done



###########################################################
##########	     		debug TESTS HEre						###########
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
	if ! [[ $DISK_SIZE =~ $re ]] ; then
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
	read -p "Write memory size (MB): " memory_size
	if ! [[ $memory_size =~ $re ]] ; then
		read -n 1 -s -p "Size can contain only numbers!\nPress any key to continue"
		continue
	fi
	break
done

$VB modifyvm $NAME --memory $memory_size

# STORAGE CONTROLER FOR NOW WITHOUT SELECTION
$VB storagectl $NAME --name "IDE Controller" --add ide
$VB storageattach $NAME --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium /home/$USER/VirtualBox\ VMs/$NAME/$NAME.vdi

while true; do
	clear
	read -e -p "Write here path to your .iso drive wchich you want use to install: " ISO_PATH
	#exist=$(ls $ISO_PATH)     DELETE?
	if [ ! -f $ISO_PATH ] ; then
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
	read -p "Write how many network cards you want: " cards_count
	if ! [[ $cards_count =~ $re ]] ; then
		read -n 1 -s -p "Only numbers are allowed!\nPress any key to continue"
		continue
	fi
	break
done
for (( i=0; i<$cards_count; i++ )); do
	clear
	for ((j=0; j < 5; j++)); do
		echo "$(($j + 1)). ${network_card_type[$j]}"
	done
	read -p "Write number which type of card it will be: " CARD_TYPE
	case "$CARD_TYPE" in
		1)
			function_cable_connected
			$VB modifyvm $NAME --nic$(($i+1)) nat --cableconnected$(($i+1)) $cable_connected
			;;
		2)
			;;
		3)
			while true; do
				clear
				for ((j=0; j < ${#network_interfaces[@]}; j++)); do
					printf "$(($j+1)). ${network_interfaces[$j]}\n"
				done
				read -p "Write number which interface wil bridge: " BRIDGE_ADAPTER
				if  ! [[ $BRIDGE_ADAPTER =~ $re ]] || [ $BRIDGE_ADAPTER -lt 1 ] || \
					[ $BRIDGE_ADAPTER -gt ${#network_interfaces[@]} ]; then
					read -n 1 -s -p "You have written wrong values!\nPress any key to continue"
					continue
				fi
				break
			done
			function_cable_connected
			$VB modifyvm $NAME --nic$(($i+1)) bridged --bridgeadapter$(($i+1)) \
				$network_interfaces[$(($BRIDGE_ADAPTER-1))] --cableconnected$(($i+1)) $cable_connected
			;;
		4)
			;;
		5)
			;;
		*)
			read -n 1 -s -p "You have written wrong values!\nPress any key to continue"
	esac
done
read -p "Do you want to start machine?\nremember to change boot order after installation!\n
	Write  y  if yes, anything else if no: " DECISION
case option in
	y)
		$VB startvm $NAME &
		;;
	*)
		clear
		exit 0
esac
