#!/bin/bash
#######################################
#######################################
#
#	interfaces probably fucked up
#
#
#######################################
#######################################
# create machine
# create disk
# mount .iso
# setting bridge

# variables
RE='^[0-9]+$' 
VB="VBoxManage"
NETWORK_CARD_TYPE=("NAT" "NAT Network" "Bridged" "Inner Net" "Isolated Network")
NETWORK_INTERFACES=($(netstat -i | awk '{if ( NR > 2 ) print $1}'))

###############################
#####			  #####
#####      FUNCTIONS      #####
#####                     #####
###############################

function FUNCTION_CABLE_CONNECED(){
	while true; do
		clear
		read -p "Cable connected? Write full words. (on/off): " CABLE_CONNECTED
			if [ $CABLE_CONNECTED == "on" ] || [ $CABLE_CONNECTED == "no "]; then
				break
			else
				read -n 1 -s -r -p "Your input is not corrected!\nPress any key to continue"
			fi
	done
	clear
}
###########################################################
##########	     DEBUG TESTS HERE		###########
###########################################################
for ((i=0; i < ${#NETWORK_INTERFACES[@]}; i++)); do
	printf "$(($i+1)). ${NETWORK_INTERFACES[$i]}\n"
done
exit 0
###########################################################


###############################
#####			  #####
#####         MAIN        #####
#####                     #####
###############################
clear
printf  "Simple bash script to make VM with virtualbox cli.\n\n\n"
read -n 1 -s -r -p "Press any key to continue"
clear
read -p "Write how VM should name: " NAME


while true; do
	clear
	read -p "Write disk size (MB): " DISK_SIZE
	if ! [[ $DISK_SIZE =~ $RE ]] ; then
		echo "Size can contain only numbers!"
		read -n 1 -s -r -p "Press any key to continue"
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
	VBoxManage list ostypes | grep -A 1 ^ID: | sed -e '/--/d' -e 's/ \{1,\}/ /g' -e 's/ /;/g'| awk '{if (NR % 2 == 1) printf $0"  "; else printf $0"\n"}' | column -t | sed 's/;/ /g'
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
		echo "Size can contain only numbers!"
		read -n 1 -s -r -p "Press any key to continue"
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
#####			  #####
#####       NETWORK       #####
#####                     #####
###############################

# ONLY NAT AND BRIDHE WORKING NOW
clear
while true; do
	read -p "Write how many network cards you want: " CARDS_COUNT
	if ! [[ $CARDS_COUNT =~ $RE ]] ; then
		echo "Only numbers are allowed!"
		read -n 1 -s -r -p "Press any key to continue"
		continue
	fi
	break
done
for (( i=1; i<=CARD_COUNT; i++ )); do
	clear
	for ((i=1; i < 6; i++)); do echo "$(($i + 1)). ${NETWORK_CARD_TYPE[$i]}"; done
	read -p "Write number which type of card it will be: " CARD_TYPE
	if [ $CARD_TYPE -eq 1 ]; then
		FUNCTION_CABLE_CONNECED()
		$VB modifyvm $NAME --nic$(($i+1)) nat --cableconnected$(($i+1)) $CABLE_CONNECTED
	elif [ $CARD_TYPE -eq 2 ]
# nat network	FUNCTION_CABLE_CONNECED()
	elif [ $CARD_TYPE -eq 3 ]
		while true; do
			clear
			for ((i=0; i < ${#NETWORK_INTERFACES[@]}; i++)); do
				print $(($i+1)). ${NETWORK_INTERFACES[$i]}
			done
			read -p "Write number which interface wil bridge: " BRIDGE_INTERFACE
			if  ! [[ $BRIDGE_INTERFACE =~ $RE ]] || [ $BRIDGE_INTERFACE -lt 1 ] || [ $BRIDGE_INTERFACE -gt ${#NETWORK_INTERFACES[@]} ]; then
				echo "You have written wrong values!"
				read -n 1 -s -r -p "Press any key to continue"
				continue
			fi
			break
		done
		FUNCTION_CABLE_CONNECED()
		$VB modifyvm $NAME --nic$(($i+1)) bridged --cableconnected$(($i+1)) $CABLE_CONNECTED
# bridge	FUNCTION_CABLE_CONNECED()
	elif [ $CARD_TYPE -eq 4 ]
# iner net	FUNCTION_CABLE_CONNECED()
	elif [ $CARD_TYPE -eq 5 ]
# isolated	FUNCTION_CABLE_CONNECED()
	else 
		FUNCTION_CABLE_CONNECED()
	fi
	$VB modifyvm $NAME
done

##############################
$VB modifyvm $NAME --nic1 bridged --bridgeadapter1 wlp3s0 --cableconnected1 on






read -p "Do you want to start machine? Write  y  if yes, anything else if no: " DECISION
if [ $DECISION == "y" ] ; then
	$VB startvm $NAME &
else
	exit 0
fi
exit 0