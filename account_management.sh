#!/bin/bash

# Created July 5 2016

# Author: Clarence Mills

# Depeendency: PKI key in place on each remote-server to provide secure passwordless connection

# Sudo files in place to allow usage of User account managment applications


#set -xv

user=acsc

today=`date +%Y-%m-%d`

now="time,`date +%r`"

log=~/log/logfile-$today.txt

lockfile=~/lockfile

 

create_lock(){

if [ -e $lockfile ]; then

    echo "Application in use"

    exit 1

else

    touch $lockfile

fi

}

 

removelock(){

if [ -e $lockfile ]; then

    rm $lockfile

fi

}


usage(){

    scriptname=`basename $0`

    echo ""

    echo "Scotiabank Account management script for managing user accounts on Linux systesms"

    echo "Remote user accounts are created and modified on mass from this central server (`hostname`)."

    echo ""

    echo "Usage: $scriptname [Options]"

    echo ""

    echo "Options:"

    echo ""

    echo -e "  -cc| create-config \t\t create ssh config file"

    echo -e "  -h | help \t\t\t Display this help message"

    echo -e "  -m | menu \t\t\t Administration of user account"

    echo -e "   \t\t\t Search for User"

    echo -e "   \t\t\t Add user"

    echo -e "   \t\t\t Delete user"

    echo -e "   \t\t\t Reset password"

    echo -e "   \t\t\t Lock Account"

    echo -e "   \t\t\t Unlock Account"

    echo -e "   \t\t\t PamTally2 reset"

    echo -e "   \t\t\t Add user to group"

    echo -e "   \t\t\t Remove a user From a group"

    echo -e "   \t\t\t Change existing group ID"

    echo -e "   \t\t\t Check account Status"

    echo ""

    echo -e "  -o | oneline \t\t\t execute a command on a remote server"

    echo ""

    echo "Example:"

    echo -e "  $scriptname menu"

    echo -e "  $scriptname -m"

    echo ""

    echo -e "  $scriptname -o tor-lx-svn-d01 \"cat /etc/passwd\" "

    echo ""

    echo -e "Note:"

    echo "When prompted you will be required to enter the complete path to a file containing IP addresses or hostname of the servers which will be used for account modification."

}

sshconfig(){

config=~/config

if [ -e config ]; then

    echo "removing old file"

    rm config

    echo "creating new ssh config file"

    echo "Host *" >> $config

    echo -e "\t\t User acsc" >> $config

    echo -e "\t\t IdentityFile ~/.ssh/id_rsa:" >> $config

    echo -e "\t\t CheckHostIP no:" >> $config

    echo -e "\t\t Compression yes" >> $config

    echo -e "\t\t CompressionLevel 7" >> $config

    echo -e "\t\t PreferredAuthentications publickey" >> $config

    echo -e "\t\t AddressFamily inet" >> $config

    echo -e "\t\t ServerAliveInterval 600" >> $config

    echo -e "\t\t ServerAliveCountMax 5" >> $config

    echo -e "\t\t ControlPath ~/.ssh/master-%r@%h:%p" >> $config

    echo -e "\t\t ControlMaster auto" >> $config

    echo -e "\t\t ControlPersist 10m" >> $config

    echo -e "\t\t #userKnownHostsFile /dev/null" >> $config

    echo -e "\t\t StrictHostkeyChecking no" >> $config 
else
    echo "creating new ssh config file"

    echo "Host *" >> $config

    echo -e "\t\t User acsc" >> $config

    echo -e "\t\t IdentityFile ~/.ssh/id_rsa:" >> $config

    echo -e "\t\t CheckHostIP no:" >> $config

    echo -e "\t\t Compression yes" >> $config

    echo -e "\t\t CompressionLevel 7" >> $config

    echo -e "\t\t PreferredAuthentications publickey" >> $config

    echo -e "\t\t AddressFamily inet" >> $config

    echo -e "\t\t ServerAliveInterval 600" >> $config

    echo -e "\t\t ServerAliveCountMax 5" >> $config

    echo -e "\t\t ControlPath ~/.ssh/master-%r@%h:%p" >> $config

    echo -e "\t\t ControlMaster auto" >> $config

    echo -e "\t\t ControlPersist 10m" >> $config

    echo -e "\t\t #userKnownHostsFile /dev/null" >> $config

    echo -e "\t\t StrictHostkeyChecking no" >> $config

fi

}

 

oneline(){

#set -xv

rmt_server=$1

rmt_execute="$2"

 

ssh -qt $user@$rmt_server "$rmt_execute"

 

# Send to log file

echo one-line,$rmt_server,commandentered,"$rmt_execute" $now >> $log

}


check_username(){

#set -x

rmt_user=$1


if [ -z $rmt_user ];then

        echo -ne "\t\t\t Enter the username to search for. "

        read rmt_user

else

        echo -e "\t\t\t Searching for $rmt_user"

fi

}


check_servername(){

#set -x

rmt_server=$1


if [ -f servers.txt ];then

    echo -ne "\t\t\t Found servers.txt file in local directory, using file "

    rmt_server=servers.txt

    echo $rmt_server

else

    if [ -z $rmt_server ];then

            echo -ne "\t\t\t Enter servername. "

            read rmt_server

            echo $rmt_server

    else

            echo $rmt_server

    fi

fi

}


search(){

#set -vx

rmt_user=$1

rmt_server=$2

searchlog=~/log/search_results.txt

searchresults=""

groupsearch=""

 

if [ -z $rmt_server ]; then

    echo -ne "\t\t\t Enter file containing the list of servers. "

    read file

    for line in $(cat $file); do

        echo ""

        rmt_server=$line

        echo Search for $rmt_user on $rmt_server $now | tee -a $searchlog

 

        # Search /etc/passwd file

        echo -ne "/etc/passwd file: " | tee -a $searchlog

            ssh -q $user@$rmt_server grep $rmt_user /etc/passwd | tee -a $searchlog

        result=$?

        if [ "$result" == 0 ]; then

            searchresults="$rmt_user found"

        else

            echo "$rmt_user not found"

            searchresults="$rmt_user not found"

        fi

 

        # Searching /etc/group file

        if [ "$result" == 0 ]; then

            echo    

        else

            echo -ne "/etc/group " | tee -a $searchlog

                ssh -q $user@$rmt_server grep $rmt_user /etc/group | tee -a $searchlog

            groupresult="$?"

            if [ $groupresult == 0 ]; then

                groupsearch="group found"

            else

                echo "$rmt_user group not found"

                groupsearch="group not found"

            fi

        fi

    echo "" >> $searchlog

    done

else

    file=$rmt_server

    for line in $(cat $file); do

        rmt_server=$line

        echo $rmt_server

 

        # Searching /etc/passwd file

        echo -n "/etc/passwd file "

            ssh -q -t $user@$rmt_server grep $rmt_user /etc/passwd

        result=$?

        if [ $result != 0 ]; then

            echo -n "$rmt_user not found"

            echo "$rmt_server search,$rmt_user,not found,$result $now" >> $searchlog

        else

            echo -n "$rmt_user found"

            echo "$rmt_server search,$rmt_user,found,$result $now" >> $searchlog

        fi

 

        # Searching /etc/group file

        echo -n "/etc/group file "

            ssh -q $user@$rmt_server grep $rmt_user /etc/group $searchlog

        groupresult="$?"

        if [ $groupresult != 0 ]; then

            echo "$rmt_user not found"

        else

            echo "$rmt_server search,$rmt_user,group found,$rroupresult $now" >> $searchlog

        fi

    done

fi

}

 

add-user(){

#set -xv

# Create hashed password

pass=`openssl passwd -crypt Temp1234`

 

echo ""

echo -e "\t\t\t Add user option"

echo ""

 

echo -ne "\t\t\t Enter username: "

read username

 

echo -ne "\t\t\t Enter Comment: "

read "comment"

 

echo -ne "\t\t\t Enter UID: "

read uuid

 

echo -ne "\t\t\t Enter GID: "

read groupid

 

echo -ne "\t\t\t Other groups: "

read multigroup

 

echo -ne "\t\t\t Enter home directory: "

read location

 

file=$2

if [ -z $file ];then

    echo -ne  "\t\t\t Enter file containing list of servers. "

    read file

    for line in $(cat $file);

    do

        rmt_server=$line

        echo ""

        echo $rmt_server

 

        # Creating user group in /etc/group

        echo "Adding user:$username group to /etc/group"

        ssh -q -t $user@$rmt_server sudo groupadd $username -g $groupid

        groupresult=$?

 

        # Create User   

        echo "Adding user:$username to /etc/passwd"

        ssh -q -t $user@$rmt_server sudo useradd -u $uuid -g $groupid -m -d $location -p $pass $username -s /bin/bash

        userresult=$?

        #Change profile permissions to 640 as peer Abdul Moeed

        echo "Changing shell profile permissions to 640"

        ssh -q -t $user@$rmt_server sudo chmod 640 $location/.bashrc

        ssh -q -t $user@$rmt_server sudo chmod 640 $location/.bash_profile

        ssh -q -t $user@$rmt_server sudo chmod 640 $location/.bash_logout

        ssh -q -t $user@$rmt_server sudo chmod 640 $location/.kshrc

 

        # Adding user to multigroup

        if [ -z $multigroup ]; then

            echo "Not adding to other groups, nothing entered"

            usermodresult="nothing entered from user input"

            added=0

        else

            ssh -q -t $user@$rmt_server sudo usermod -G $multigroup $username

            usermodresult=$?

            added=$multigroup

        fi

 

        # Insert comment of first name

        ssh -q -t $user@$rmt_server sudo chfn -o $comment $username

        commentresults=$?

 

        # Expire password, requires user to reset on first login

        ssh -q -t $user@$rmt_server sudo chage -d 0 $username

        passwordresult=$?

 

        # Set min and max password expired dates

        ssh -q -t $user@$rmt_server sudo chage -m 90 -M 90 $username

 

        # Set 7 day before account is inactive after password expires

        ssh -q -t $user@$rmt_server sudo chage -I 3 $username

 

        # Set 7 warning days before password expires

        ssh -q -t $user@$rmt_server sudo chage -W 7 $username

 

        # log options

        echo $rmt_server add-user,$username,$uuid,$location,$userresult group,$groupid,$groupresult usermodadditions,$added,$usermodresult password-set,$passwordresult $now >> $log

        echo $log

    done

else

    for line in $(cat $file);

    do

        echo "Connected to $line"

        rmt_server=$line

        echo ""

 

        # Creating use group in /etc/group

        echo "Adding user:$username to /etc/group"

        ssh -q -t $user@$rmt_server sudo groupadd $username -g $groupid

        groupresult=$?

        echo ""

 

        # Adding user to multigroup

        if [ -z $multigroup ]; then

            echo "Nothing entered by user"

        else

            ssh -q -t $user@$rmt_server -G $multigroup $username

            usermodresult=$?

            echo $usermodresult

        fi

 

        # Create User   

        echo "Creating $username account on $rmt_server"

        ssh -q -t $user@$rmt_server sudo useradd -u $uuid -g $groupid -m -d $location -p $pass $username

        userresult=$?

 

        #Change profile permissions to 640 as peer Abdul Moeed

        echo "Changing shell profile permissions to 640"

        ssh -q -t $user@$rmt_server sudo chmod 640 $location/.bashrc

        ssh -q -t $user@$rmt_server sudo chmod 640 $location/.bash_profile

        ssh -q -t $user@$rmt_server sudo chmod 640 $location/.bash_logout

        ssh -q -t $user@$rmt_server sudo chmod 640 $location/.kshrc

 

        # Insert comment

        ssh -q -t $user@$rmt_server sudo chfn -o $comment $username

        commentresults=$?

 

        # Expire password requiring user to reset on first login

        ssh -q -t $user@$rmt_server sudo chage -d 0 $username

        passwordresults=$?

 

        # Set min and max password expired dates

        ssh -q -t $user@$rmt_server sudo chage -E $today -m 90 -M 90 $username

 

        # Set 7 day before account is inactive after password expires

        ssh -q -t $user@$rmt_server sudo chage -I 3 $username

 

        # Set 7 warning days before password expires

        ssh -q -t $user@$rmt_server sudo chage -W 7 $username

        echo $?

 

        # log options

        echo $rmt_server add-user,$username,$uuid,$location,$userresult $groupid,$groupresult password-set,$passwordresults $now >> $log

        echo $log

    done

fi

}

 

delete-user(){

#set -xv

 

echo ""

echo -e "\t\t\t Delete user option"

echo ""

 

if [ -z $rmt_user ];then

    echo -ne "\t\t\t Enter username. "

    read rmt_user

fi

 

if [ -z $file ];then

    echo -ne "\t\t\t Enter file containing list of servers. "

    read file

    for line in $(cat $file);

    do

        rmt_server=$line

        echo ""

        echo -e "\t\t\t\t\t ===== $rmt_server ====="

 

        echo "Deleting $rmt_user from /etc/passwd"

        ssh -q -t $user@$rmt_server sudo userdel -f -r $rmt_user

        result=$?

        if [ $result == 0 ]; then

            echo "$rmt_user deleted from /etc/passwd successfully"

            echo $rmt_server delete-user,$rmt_user,$result $now >> $log

        else

            echo "Deleted $rmt_user from /etc/group"

            ssh -q -t $user@$rmt_server sudo groupdel $rmt_user

            groupdelresult=$?

            echo $rmt_server delete-user,$rmt_user,$result delete-group,$rmt_user,$groupdelresult $now >> $log

        fi

    done

else

    for line in $(cat $file);

    do

        rmt_server=$line

        echo ""

        echo -e "\t\t\t\t\t ===== $rmt_server ====="

 

        echo "Deleting $rmt_user /etc/passwd and /etc/group entries"

        ssh -q -t $user@$rmt_server sudo userdel -f -r $rmt_user

        result=$?

        if [ $result == 0 ]; then

            echo "$rmt_user deleted from /etc/passwd successfully"

        else

            echo "Deleting $rmt_user group from /etc/group"

            ssh -q -t $user@$rmt_server sudo groupdel $rmt_user

            groupdelresult=$?

            echo $groupdelresult

        fi

        ssh -q -t $user@$rmt_server sudo groupdel $rmt_user

        groupdelresult=$?

 

        # Send output to log file

        echo $rmt_server delete-user,$rmt_user $result delete-group,$rmt_user,$groupdelresult $now >> $log

    done

fi

 

}

 

check(){

rmt_user=$1

 

if [ -z $rmt_user ];then

    echo -ne "\t\t\t Enter username. "

    read rmt_user

fi

 

if [ -z $file ]; then

    echo -ne "\t\t\t Enter file containing list of servers. "

    read file

    for line in $(cat $file); do

        rmt_server=$line

        echo ""

        echo -e "\t\t\t\t\t ===== $now $rmt_server =====" | tee -a $rawlog

        echo ""

r

 

        echo "User: $rmt_user"

        echo -n "Passwd file: "

        ssh -q -t $user@$rmt_server grep $rmt_user /etc/passwd | tee -a $rawlog

        echo -n "User and groups: "

        ssh -q -t $user@$rmt_server sudo id $rmt_user | tee -a $rawlog

        echo ""

        echo "Account Status:"

        ssh -q -t $user@$rmt_server sudo chage -l $rmt_user | tee -a $rawlog

        echo ""

        echo "Verify failed SSH attempts:"

        ssh -q -t  $user@$rmt_server sudo pam_tally2 --user=$rmt_user | tee -a $rawlog

    done

else

    for line in $(cat $file); do

        rmt_server=$line

        echo ""

        echo -e "\t\t\t\t\t ===== $now $rmt_server =====" | tee -a $rawlog

        echo ""

 

        echo "User: $rmt_user"

        echo -n "Passwd file: "

        ssh  $user@$rmt_server grep $rmt_user /etc/passwd | tee -a $rawlog

        echo -n "User and groups: "

        ssh -q -t  $user@$rmt_server sudo id $rmt_user | tee -a $rawlog

        echo ""

        echo "Account Status:"

        ssh -q -t $user@$rmt_server sudo chage -l $rmt_user | tee -a $rawlog

        echo ""

        echo "Verify failed SSH attempts:"

        ssh -q -t $user@$rmt_server sudo pam_tally2 --user=$rmt_user | tee -a $rawlog

        echo ""

    done

fi

}

 

reset-pass(){

#set -x

# Create hashed password

pass=`openssl passwd -crypt Temp1234`

 

echo ""

echo -e "\t\t\t Reset password option"

echo -ne "\t\t\t Enter username: "

read username

 

echo -ne "\t\t\t Enter file: "

read file

 

for line in $(cat $file); do

    rmt_server=$line

    echo ""

    echo -e "\t\t\t\t\t ===== $rmt_server ====="

    echo ""

 

    echo "Setting password to corporate default for $username"

    ssh -q -t $user@$rmt_server sudo usermod -p $pass $username

    result="$?" 

 

    # Expire password, requires user to reset on first login

    ssh -q -t $user@$rmt_server sudo chage -d 0 $username

    expireresult=$?

 

    if [ $result == 0 ]; then

        echo "Password reset to default for $username"

        echo $rmt_server password-reset,$username,$result expire,$expireresult $now >> $log

    else

        echo "Password reset not completed for $username."

        echo $rmt_server password-reset,$username,$result expire,$expireresult $now >> $log

    fi

done

}

 

lock-account(){

#set -xv

 

echo ""

echo -e "\t\t\t Lock account option"

echo ""

echo -ne "\t\t\t Enter username: "

read username

 

echo -ne "\t\t\t Enter file. "

read file

 

for line in $(cat $file); do

        rmt_server=$line

    echo ""

    echo -e "\t\t\t\t\t ===== $rmt_server ====="

    echo ""

 

        echo "Locking $username account"

        ssh -q -t $user@$rmt_server sudo usermod -L $username

        result="$?"

    echo "Change Directory permission"

    ssh -q -t $user@$rmt_server sudo chmod 000 /home/$username

    changeddirresults=$?

 

    if [[ "$result" == 0 && "$changeddirresults" == 0 ]]; then

            echo "$username account locked and directory permissions modified"

        echo $rmt_server account-lock,$username,$result,changedirpermissions,$changeddirresults $now >> $log

    else

            echo "Could not lock $username account"

        echo $rmt_server account-lock,$username,$result,changeddirpermissions,$changeddiresults $now >> $log

    fi

done

}

 

unlock-account(){

echo ""

echo -e "\t\t\t Unlock account option"

echo ""

echo -ne "\t\t\t Enter username: "

read username

 

echo -ne "\t\t\t Enter file: "

read file

 

for line in $(cat $file); do

        rmt_server=$line 

    echo ""

    echo -e "\t\t\t\t\t ===== $rmt_server ====="

    echo ""

 

        echo "$username account will be ulocked"

        ssh -q -t $user@$rmt_server sudo usermod -U $username

        result="$?"

 

    echo "Changing /home/$username permissions to 700"

    ssh -q -t $user@$rmt_server sudo chmod 700 /home/$username

    changeddirresults=$?

 

    if [[ $result == 0 && "$changeddirresults" == 0 ]]; then

            echo "$username account is unlocked and /home/$username changed to 700"

        echo $rmt_server unlock-account,$username,$result,changedirresults,$changeddirresults $now >> $log

    else

            echo "Could not unlock account"

        echo $rmt_server unlock-account,$username,$result,changeddirpermissions,$changedddirresults $now >> $log

    fi

done

}

 

pamtally2(){

echo ""

echo -e "\t\t\t Reset Failed SSH attempts option"

echo ""

echo -ne "\t\t\t Enter username: "

read username

 

echo -ne "\t\t\t Enter file: "

read file

 

for line in $(cat $file); do

        rmt_server=$line

    echo ""

    echo -e "\t\t\t\t\t ===== $rmt_server ====="

    echo ""

 

        echo "Resetting $username password to default"

        ssh -q -t $user@$rmt_server sudo pam_tally2 --user=$username --reset

        result="$?"

 

    if [ $result == 0 ]; then

            echo "$username account reset"

        echo $rmt_server pammtally2-reset,$username,$result $now >> $log

    else

            echo "Could not reeset account"

        echo $rmt_server pammtall2y-reset,$username,$result $now >> $log

    fi

done

}

 

addtogroup(){

echo ""

echo -e "\t\t\t Add user to group option"

echo ""

echo -ne "\t\t\t Enter user name: "

read username

 

echo -ne "\t\t\t Enter groupname (Seperate multiple groups by comma's): "

read group

 

echo -ne "\t\t\t Enter file containing list of servers: "

read file

 

for line in $(cat $file); do

        rmt_server=$line

    echo ""

    echo -e "\t\t\t\t\t ===== $rmt_server ====="

    echo ""

 

        echo "Adding $username to $group"

        ssh -q -t $user@$rmt_server sudo usermod -a -G $group $username

        result="$?"

    if [ $result == 0 ]; then

            echo "$username added to $group"

        ssh -q -t $user@$rmt_server sudo id $username

        # Send data to log file

        echo $rmt_server add-to-group,$username,$group,$result $now >> $log

    else

            echo "Could not add $username to $group"

        # Send data to log file

        echo $rmt_server add-to-group,$username,$group,$result $now >> $log

    fi

done

}

 

deletefromgroup(){

# Administer group, add, remove user from group

echo ""

echo -e "\t\t\t Delete a user from a group option"

echo ""

echo -ne "\t\t\t Enter username: "

read username

echo -ne "\t\t\t Enter group name: "

read groupname

echo -ne "\t\t\t Enter file containing list of servers: "

read file

 

for line in $(cat $file); do

    rmt_server=$line

    echo ""

    echo -e "\t\t\t ===== $rmt_server ====="

    echo ""

    

    echo  "Deleting $username from $groupname"

    ssh -q -t $user@$rmt_server sudo groupmems -g $groupname -d $username

    deletefromresult=$?

    if [ $deletefromresult == 0 ]; then

        echo ""

        echo -e "\t\t\t $username deleted from $groupname"

        echo $rmt_server deletefrom-group,$username,$groupname,$deleteresult $now >> $log   

    else

        echo -e "\t\t\t Could not delete $username from $groupname"

        echo $rmt_server deletefrom-group,$username,$groupname,$deleteresult $now >> $log   

    fi

done

}

 

changeprimarygroup(){

echo ""

echo -e "\t\t\t Change primary group option"

echo ""

echo -ne "\t\t\t Enter user name: "

read username

 

echo -ne "\t\t\t Enter group new name or GUID: "

read group

 

echo -ne "\t\t\t Enter file containing list of servers: "

read file

 

for line in $(cat $file); do

        rmt_server=$line

    echo ""

    echo -e "\t\t\t\t\t ===== $rmt_server ====="

    echo ""

 

        echo "Change primary group for $username to $group"

        ssh -q -t $user@$rmt_server sudo groupmod -g $group $username

        result="$?"

    if [ $result == 0 ]; then

        echo ""

            echo "$username changed primary group to $group"

            ssh -q -t $user@$rmt_server sudo id $username

        # Send results to log file

        echo $rmt_server changeprimarygroup,$username $group,$results $now >> $log

    else

            echo "Could not change to $group"

        primarygroupchangeresults=$?

        # Send results to log file

        echo $rmt_server changeprimarygroup,$username $group,$results $now >> $log

    fi

done

}

 

creategroup(){

echo ""

echo -ne "\t\t\t Enter group name: "

read groupname

echo -ne "\t\t\t Enter group id: "

read groupid

echo ""

echo -ne "\t\t\t Enter file containing list of servers: "

read file

 

for line in $(cat $file); do

    rmt_server=$line

    echo ""

        echo -e "\t\t\t\t\t ===== $rmt_server ====="

        echo "" 

    

    echo "Creating Group $groupname"

    ssh -q -t $user@$rmt_server sudo groupadd -g $groupid $groupname

    result=$?

 

    if [ "$result" == 0 ]; then

        echo "Group $groupname created successfully"

        # Send results to log file

        echo $rmt_server creategroup,$groupname,$groupid,$results $now >> $log

    else

        echo "Could not create group $groupname"

        # Send results to log file

        echo $rmt_server creategroup,$groupname,$groupid,$results $now >> $log

    fi

done

}

 

removegroup(){

echo ""

echo -ne "\t\t\t Enter group name: "

read groupname

echo -ne "\t\t\t Enter file containing list of servers: "

read file

 

for line in $(cat $file); do

    rmt_server=$line

    echo ""

    echo -e "\t\t\t ===== $rmt_server ====="

    echo ""

 

    echo "Removing group $groupname"

    ssh -q -t $user@$rmt_server sudo groupdel $groupname

    result=$?

 

    if [ "$result" == 0 ]; then

        echo "Group $groupname deleted successfully"

        # Send to log file

        echo $rmt_server removegroup,$groupname,$result $now >> $log

    else

        echo "Could not delete $groupname"

        echo $rmt_server removegroup,$groupname,$result $now >> $log

    fi

done

}

 

menu(){

 

menu(){

    clear

    echo -e ""

        echo -e "\t\t\t --------------------------------"

        echo -e "\t\t\t    User Account Administration  "

        echo -e "\t\t\t --------------------------------"

    echo -e ""

        echo -e "\t\t\t 1. Search User"

        echo -e "\t\t\t 2. Add User"

        echo -e "\t\t\t 3. Delete User"

        echo -e "\t\t\t 4. Reset password"

        echo -e "\t\t\t 5. Lock Account  "

        echo -e "\t\t\t 6. Unlock Account"

        echo -e "\t\t\t 7. Pam Tally2 reset"

        echo -e "\t\t\t 8. Add group"

        echo -e "\t\t\t 9. Add user to group"

        echo -e "\t\t\t 10. Remove a user from a group"

        echo -e "\t\t\t 11. Change existing group ID"

        echo -e "\t\t\t 12. Remove a Group"

        echo -e "\t\t\t 13. Check account status"

        echo -e "\t\t\t 14. Exit"

    echo -e ""

}

 

    menu

    echo -en "\t\t\t Enter selection from 1-14: "

    read choice

    case $choice in

    1)

        check_username $rmt_user

        search $rmt_user $rmt_server

        removelock

        sleep 10

        $(basename $0) -m

        ;;

    2)

        add-user

        removelock

        $(basename $0) -m

        ;;

    3)

                delete-user

        removelock

        $(basename $0) -m

        ;;

    4)

        reset-pass

        removelock

        $(basename $0) -m

        ;;

    5)

        lock-account

        removelock

        $(basename $0) -m

        ;;

    6)

        unlock-account

        removelock

        $(basename $0) -m

        ;;

    7)

        pamtally2

        removelock

        $(basename $0) -m

        ;;

    8)

        creategroup

        removelock

        $(basename $0) -m

        ;;

    9)

        addtogroup

        removelock

        $(basename $0) -m

        ;;

    10)

        deletefromgroup

        removelock

        $(basename $0) -m

        ;;

    11)

        changeprimarygroup

        removelock

        $(basename $0) -m

        ;;

    12)

        removegroup

        removelock

        $(basename $0) -m

        ;;

    13)

        check

        removelock

        $(basename $0) -m

        ;;

    14)

        removelock

        exit 0

        ;;

    *)  

        removelock

        $(basename $0) -m

        ;;

    esac

}


# Start program

rmt_user=$2

rmt_server=$3


case $1 in

menu|-m)

    create_lock

   menu

    removelock

    ;;  

oneline|-o)

    create_lock

    oneline $2 "$3"

    removelock

    ;;

create-config|-cc)

    sshconfig

    ;;

-h|help|*)

        usage

        ;;

esac
