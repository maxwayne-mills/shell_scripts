#!/usr/bin/env bash

# Get the  token information from local file
TOKEN="$(cat ~/.linode-cli | grep -i token | sort -u | awk 'BEGIN { FS = "=" };{print $2}' | sed 's/ //g')"

create (){
    curl -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -X POST -d '{
        "swap_size": 512,
        "image": "linode/debian9",
        "root_pass": "aComplexP@ssword",
        "stackscript_id": 10079,
        "stackscript_data": {
        "gh_username": "linode"
        },
        "authorized_keys": [
        "ssh-rsa AAAA_valid_public_ssh_key_123456785== user@their-computer"
        ],
        "booted": true,
        "label": "linode-srv1",
        "type": "g5-nanode-1",
        "region": "us-east",
        "group": "Linode-Group"
    }' \
    https://api.linode.com/v4/linode/instances
    }

    delete (){
        curl -H "Authorization: Bearer $TOKEN" \
    -X DELETE \
    https://api.linode.com/v4/linode/instances/8032604
    }

case $1 in

list)
        linode-cli linodes list
        ;;

create)
        create
        ;;
delete)
        delete
        ;;
*) 
        echo "$0  list | create | delete"
        ;;
esac