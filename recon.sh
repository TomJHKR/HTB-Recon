#!/bin/bash


#Reset
NC='\033[0m'		# Text Reset
BOLD='\033[1m'		# Bold
# Regular Colors
RED='\033[0;31m'	# Red
GREEN='\033[0;32m'      # Green
YELLOW='\033[0;33m'	# Yellow
BLUE='\033[0;34m'       # Blue

# Function to aid with nice printing
function prpr {
	local msg=$1
	local col=$2
	echo -e "${col}${BOLD}$1${NC}"
}

# Check if there are args
# Ensure that IP is provided
if [ -z $1 ]
then
	prpr 'IP not provided' "${RED}"
fi

# Ensure that domain is provided
if [ -z $2 ]
then
	prpr 'Domain not provided' "${RED}"
fi

# Ensure that a directory is provided
if [ -z $3 ]
then
	prpr 'Working directory not provided' "${RED}"
fi

# Variables for ip & domain & directory
ip=$1
domain=$2
dir=$3

# Ask user to add the ip & domain combo to host file
prpr 'Add domain to hosts file: (Y/N)' "${BLUE}"
echo -n ""
read add
if [[ $add == [yY] ]]
then
	sudo -- sh -c -e  "echo '$ip $domain' >> /etc/hosts"
else
	prpr 'Not adding to hosts file - Continuing' "${YELLOW}"
fi

# Default wordlist sizes
gbsize='medium.txt'

# get size for gobuster
prpr 'Gobuster wordlist size: Small / Medium - (s/m)'
echo -n ""
read gobusters
if [[ $gobusters == [sS] ]]
then
	gbsize='small.txt'
	prpr "Using small Gobuster wordlist" "${GREEN}"
else
	prpr "Using medium Gobuster wordlist" "${YELLOW}"
fi

# Create working directory and navigate there
mkdir ~/Desktop/$3
cd ~/Desktop/$3
echo "Notes for Hack The Box Lab $3" >> $3-notes.txt
echo "IP: $1" >> $3-notes.txt
echo "Domain: $2" >> $3-notes.txt

# Create tmux session and send commands into different windows
prpr "Creating TMUX sessions" "${BLUE}"
tmux new -s htb -d

tmux split-window -h
tmux selectp -t 0

tmux split-window -v
tmux selectp -t 2

tmux split-window -v

tmux send-keys -t 0 "gobuster dir -u http://$domain -w /usr/share/wordlists/dirbuster/directory-list-2.3-$gbsize" C-m
tmux send-keys -t 1 "ffuf -w ~/Desktop/Wordlists/Subdomain.txt -u http://$domain -H "Host:FUZZ.$domain" -c -mc 200" C-m
tmux send-keys -t 2 "nmap -sV -sC $ip" C-m
tmux send-keys -t 3 "nvim $3-notes.txt" C-m

# Finish
prpr "Usage: 'tmux a -t htb'" "${BLUE}"
tmux a -t htb
