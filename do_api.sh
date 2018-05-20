#!/usr/bin/env bash

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
    curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" "https://api.digitalocean.com/v2/account" | jq -a
}

droplet(){
    token=$1
    curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" "https://api.digitalocean.com/v2/droplets?page=1&per_page=1" | jq -a
}

case $1 in
account)
        get_token
        account $token
        ;;
droplet)
        get_token
        droplet $token
        ;;
*)
        echo "$0: account | droplet"
        ;;
esac