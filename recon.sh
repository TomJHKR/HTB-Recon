#!/bin/bash


#Reset
NC='\033[0m'		# Text Reset
BOLD='\033[1m'		# Bold
# Regular Colors
RED='\033[0;31m'	# Red
GREEN='\033[0;32m'      # Green
YELLOW='\033[0;33m'	# Yellow
BLUE='\033[0;34m'       # Blue


function prpr {
	local msg=$1
	local col=$2
	echo -e "${col}${BOLD}$1${NC}"
}

if [ "$#" -eq "0" ]
	then
		echo -e "${RED}${BOLD}Arguments not provided${NC}"
fi

if [ -z $1 ]
then
	prpr 'IP not provided' "${RED}"
fi

if [ -z $2 ]
then
	prpr 'Domain not provided' "${RED}"
fi

ip=$1
domain=$2

prpr 'Beginning Nmap Scan' "${GREEN}"

nmap -sV -sC $ip

prpr 'Add domain to hosts file: (Y/N)' "${BLUE}"
echo -n ""
read add
if [[ $add == [yY] ]]
then
	sudo -- sh -c -e  "echo '$ip $domain' >> /etc/hosts"
else
	prpr 'Not adding to hosts file - Continuing' "${YELLOW}"
fi

tmux new -s htb -d
tmux new-window -d -t htb -n DASH
tmux split-window -h -t htb:DASH.0
tmux split-window -v -t htb:DASH.1
tmux send-keys -t htb:DASH.0 "gobuster dir -u http://$domain -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
tmux send-keys -t htb:DASH.1 "ffuf -w /usr/share/wordlists/dirb/big.txt -u http://$domain/FUZZ"
