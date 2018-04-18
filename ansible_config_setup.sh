#!/bin/bash
# Author: Clarence Mills
# Shell script to extract, ip address, server name and provider from terraform 
# state file.

# Variables
tf=$(which terraform)

# obtain computed IP address
ip_addr=$($tf show | grep -iw "ip =" | awk 'BEGIN { FS = " = " }; { print $2}')

# Get the computed server name
srv_name=$(cat terraform.tfstate | grep -i name | grep -iv "Ubuntu" | sed 's/ //g' | sed 's/"//g' | sed 's/,//g' | awk 'BEGIN { FS = ":" };{print $2}')

#Figure out the provider being users
provider=$(cat terraform.tfstate | grep -i provider | sort -u | awk 'BEGIN { FS = ":" }; { print $2 }' | sed 's/"//g' |sed 's/ //g' | awk 'BEGIN { FS = "." }; {print $2}')

# Build ansible inventory file from terraform state information
if [ "$provider" == "scaleway" ]; then
    echo "$srv_name	ansible_connection=ssh ansible_user=root	ansible_host=$ip_addr" > inventory
else
    echo "Supported Provider not found"
    echo "Providers are Scaleway"
fi

# Create Ansible configuration file
if [ -f ansible.cfg ]; then
rm ansible.cfg
tee << EOF > ansible.cfg
[defaults]
retry_files_enabled = False
host_key_checking = False
roles_path = ansible/roles
#inventory = inventory

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
#inventory = inventory

[ssh_connection]
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
scp_if_ssh = True
EOF
fi
