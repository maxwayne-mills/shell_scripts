#!/usr/bin/env bash
# Get information about droplets and Digital Ocean accessories and services using
# DIgita Ocean API
# export your token into your userspace: export token="fahfdfhafdhfdhfdfhdfhdfafhldfaf"

command="curl --silent -X GET -H"
content_type="Content-Type: application/json"  
auth="Authorization: Bearer $token"

# Digital Ocean commands
#payload="https://api.digitalocean.com/v2/images?page=1&per_page=1"
account="https://api.digitalocean.com/v2/account"
domains="https://api.digitalocean.com/v2/domains"
list_droplets="https://api.digitalocean.com/v2/droplets"
list_regions="https://api.digitalocean.com/v2/regions"



# Get account information
get_account_info(){
    #$command "$content_type" -H "$auth"  "$account" | jq 
    $command "$content_type" -H "$auth"  "$account" | jq '.account | {email: .email, verified: .email_verified, status: .status, UUID: .uuid}'
}

get_domains(){
  $command "$content_type" -H "$auth"  "$domains" | jq -S '.domains'
}

list_droplets(){
    $command "$content_type" -H "$auth"  "$list_droplets" | jq 
}

list_regions(){
    $command "$content_type" -H "$auth"  "$list_regions" | jq
}

case $1 in

account)
        get_account_info
        ;;
domain)
        get_domains 
        ;;
ld)
        list_droplets
        ;;
lr)
        list_regions
        ;;
--help | -h | *)
        clear
        app_name=$(basename $0)
        echo "$app_name Programmatically get information about your account using Digital Oceans API. "
        echo ""
       
        echo ""
        echo "Usage:"
        echo "$app_name account | domain | ld | lr | -h --help"
        echo ""
        echo "Options:"
        echo -e "    -h --help \tShow this help screen"
        echo -e "    account   \tShow account information"
        echo -e "    domain    \tShow your domains that are managed by Digital Ocean"
        echo -e "    ld        \tList your droplets"
        echo -e "    lr        \tList regions available within Digital Ocean"
        ;;
esac