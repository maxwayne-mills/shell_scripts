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
  curl -X GET -H "$content_type" -H "Authorization: Bearer $token"  "$domains" | jq -S '.domains'
}

list_droplets(){
    curl -X GET -H "$content_type" -H "Authorization: Bearer $token"  "$list_droplets" | jq 
}

list_regions(){
    curl -X GET -H "$content_type" -H "Authorization: Bearer $token"  "$list_regions" | jq
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
        echo $app_name
        echo ""
        echo "Usage:"
        echo "$app_name account | domain | ld | lr"
        echo ""
        echo "Options:"
        echo -e "\t-h --help      \tShow this help screen"
        echo -e "\taccount \tShow account information"
        echo -e "\tdomain  \tShow your domains that are managed by Digital Ocean"
        echo -e "\tld       \tList your droplets"
        echo -e "\tlr      \tList regions available within Digital Ocean"
        ;;
esac