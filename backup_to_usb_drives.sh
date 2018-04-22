#!/bin/bash

# Backup files to a mounted sdcard
# Script created on a Ubuntu trusty OS should work on any Linux OS.
# Dependencies are rsync

# Collect and check USB drive information
dest=$(mount | grep -i sdcard | awk '{print $3}')
dest2=$(mount | grep -iw Lexar | awk '{print $3}')
dest3=$(mount | grep -iw Lexar1 | awk '{print $3}')
#options="-hrptuv --delete-before --delete-excluded --exclude /home/oss/Documents/voice/*"
options="-av --delete-before --delete-excluded --exclude /home/oss/Documents/voice/*"

# find and use locally installed rsync binary
rsync=`which rsync`

clear
# Check to see if the dest exists and is read and writeable
echo "Backing up to $dest"
if [ $dest -a -rw ]; then
	echo ""&&  echo "Backing up .ssh directory"
	if [ -d $dest/ssh-configs ];then 
		rsync $options ~/.ssh $dest/ssh-configs
	else
		mkdir $dest/ssh-configs 	
		rsync $options ~/.ssh $dest/ssh-configs
	fi
		
	echo "" && echo "Backing up Git config directory"
	if [ -d $dest/git ];then 
		rsync $options ~/.gitconfig $dest/git
	else
		mkdir $dest/git
		rsync $options ~/.gitconfig $dest/git
	fi

	echo "" && echo "Backup bash aliases"
	if [ -d $dest/bash ];then
		rsync $options ~/.bash_aliases $dest/bash
	else 
		mkdir $dest/bash
		rsync $options ~/.bash_aliases $dest/bash
	fi
	
	echo "" && echo "File System usage"
	df -h $dest
else
	echo ""
	echo "sdcard is not mounted, insert and mount sdcard before proceeding"
fi 

# Check jump drive (Lexar)
echo "Backing up to $dest2"
if [ $dest2 -a -rw ]; then
	echo "" &&  echo "Backing up Document Directory"
	rsync $options ~/Documents/  $dest2/Documents
	sleep 3

	echo "" && echo "Backing up .ssh directory"
	rsync $options ~/.ssh $dest/ssh-configs
	sleep 3

	echo "" && echo "Backing up Git config directory"
	rsync $options ~/.gitconfig $dest/git
	sleep 3

	echo "" && echo "Backup passwd file"
	if [ -d $dest2/passwordsafe ];then
		rsync $options ~/Documents/*.psafe3 $dest2/passwordsafe/
	else 
		mkdir $dest/passwordsafe
		rsync $options ~/Documents/*.psafe3 $dest2/passwordsafe
	fi

	# Back up repository information
	echo "" && echo "Backup up Repository directory"
	mkdir $dest2/respositories
   	rsync $options ~/repositories/ $dest2/repositories

	echo "" && echo "$dest2: File System usage"
	df -h $dest2
else
	echo ""
	echo "Lexar drive /media/oss/Lexar is not mounted"
fi

# Check jump drive 2 (Lexar)
echo "Backing up to $dest3"
if [ $dest3 -a -rw ]; then
	echo "" && echo "Backing up Document directory"
	rsync $options ~/Documents/  $dest3/Documents

	echo "Backing up .ssh directory"
	rsync $options ~/.ssh $dest3/ssh

	echo "Backing up Git config directory"
	rsync $options ~/.gitconfig $dest3/git

	echo "" && echo "Backup passwd file"
	if [ -d $dest3/fe ];then
		rsync $options ~/Documents/*.psafe3 $dest3/passwordsafe/
	else 
		mkdir $dest3/passwordsafe
		rsync $options ~/Documents/*.psafe3 $dest3/passwordsafe/
	fi

	echo "" && echo "File System usage"
	df -h $dest3
else
	echo ""
	echo "Lexar jump drive 2 /media/oss/Lexar1 is not mounted"
	exit
fi
