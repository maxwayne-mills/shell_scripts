#!/usr/bin/env bash
# Shell script utilizing Digital Oceans API

get_token(){
    if [ -f ~/.do_api ]; then
        token=$(cat /home/cmills/.do_api | grep -i token | sort -u | awk 'BEGIN {FS="="};{print $2}' | sed 's/ //g')  
        echo "token=$token" > /home/cmills/.do_api
    else
        echo -n "Enter token: "
        read token
        echo "token=$token" > /home/cmills/.do_api
    fi
}

account(){
    token=$1
    curl --silent -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" "https://api.digitalocean.com/v2/account" | jq '..| {email, uuid }'
}

droplet(){
    token=$1
    curl --silent -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" "https://api.digitalocean.com/v2/droplets?page=1&per_page=1" | jq 
}

case $1 in
account)
        get_token
        account $token
        ;;
list)
        get_token
        droplet $token
        ;;
*)
        echo "$0: account | list"
        ;;
esac