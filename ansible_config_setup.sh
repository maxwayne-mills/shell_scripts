#!/bin/bash
# Author: Clarence Mills
# Shell script to extract, ip address, server name and provider from terraform 
# state file.

# Variables
tf=$(which terraform)
local_user=cmills
remote_user=deployuser

if [ -f Vagrantfile ]; then
    echo "Configuring for vagant"
else
    #Figure out the provider being used
    provider=$(cat terraform.tfstate | grep -i provider | sort -u | awk 'BEGIN { FS = ":" }; { print $2 }' | sed 's/"//g' |sed 's/ //g' | awk 'BEGIN { FS = "." }; {print $2}')
    echo "Configuring for inventory file for $provider"

    # Build ansible inventory file from terraform state information
    if [ "$provider" == "scaleway" ]; then
        # Get the computed server name
        srv_name=$(cat terraform.tfstate | grep -i name | grep -iv "Ubuntu" | sed 's/ //g' | sed 's/"//g' | sed 's/,//g' | awk 'BEGIN { FS = ":" };{print $2}')

        # obtain computed server IP address
        ip_addr=$($tf show | grep -iw "ip =" | awk 'BEGIN { FS = " = " }; { print $2}')

        echo "$srv_name	ansible_connection=ssh ansible_user=root	ansible_host=$ip_addr" > inventory
    elif [ "$provider" == "digitalocean" ]; then
        # Get the computed server name
        srv_name=$($tf show | grep "digitalocean_droplet." | awk 'BEGIN { FS = "." };{ print $2 }' | sed 's/://g')
        
        #obtain computed server ip address
        ip_addr=$($tf show | grep "ip_address " | awk 'BEGIN { FS = " = " }; { print $2}')
        echo "$srv_name	ansible_connection=ssh ansible_user=root	ansible_host=$ip_addr" > inventory
    else
        echo "Supported Providers are : Scaleway, Digital OCean"
    fi
fi

# Create Ansible configuration file
if [ -f ansible.cfg ]; then
rm ansible.cfg
tee << EOF > ansible.cfg
[defaults]
retry_files_enabled = False
host_key_checking = False
roles_path = ansible/roles
inventory = inventory

[ssh_connection]
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
scp_if_ssh = True
EOF
else
tee << EOF > ansible.cfg
[defaults]
retry_files_enabled = False
host_key_checking = False
roles_path = ansible/roles
inventory = inventory

[ssh_connection]
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
scp_if_ssh = True
EOF
fi

# create ansible inventory file
if [ -f inventory ]; then
rm inventory
tee << EOF > inventory
$srv_name ansible_host=$ip_addr ansible_connection=ssh ansible_user=$remote_user
EOF
else
tee << EOF > inventory
$srv_name ansible_host=$ip_addr ansible_connection=ssh ansible_user=$remote_user
EOF
fi

# Update ssh config file with new server information
ssh_file="~/.ssh/config"
tee << EOF >> $ssh_file
Host $srv_name
        user root
        Hostname $srv_name
        Port 22
        ControlMaster auto
        ControlPath /tmp/master-%r@%h:%p
        ControlPersist 10m
        ServerAliveInterval 120
        ServerAliveCountMax 5
EOF


