#!/usr/bin/env bash
# Get information about droplets and Digital Ocean accessories and services using
# DIgita Ocean API
# export your token into your userspace: export token="fahfdfhafdhfdhfdfhdfhdfafhldfaf"

command="curl --silent -X GET -H"
content_type="Content-Type: application/json"  
auth="Authorization: Bearer $token"

# Digital Ocean API URL
url="https://api.digitalocean.com/v2"

# Get account information
get_account_info(){
    account="$url/account"
    #$command "$content_type" -H "$auth"  "$account" | jq 
    $command "$content_type" -H "$auth"  "$account" | jq '.account | {email: .email, verified: .email_verified, status: .status, UUID: .uuid}'
}

get_domains(){
  domains="$url/domains"
  $command "$content_type" -H "$auth"  "$domains" | jq -S '.domains'
}

list_droplets(){
    list_droplets="$url/droplets"
    $command "$content_type" -H "$auth"  "$list_droplets" | jq 
}

list_regions(){
    list_regions="$url/regions"
    $command "$content_type" -H "$auth"  "$list_regions" | jq
}

keys(){
    keys="$url/account/keys"
    $command "$content_type" -H "$auth" "$keys"
}

case $1 in

-account)
        get_account_info
        ;;
-domain)
        get_domains 
        ;;
-keys)
        keys
        ;;
--droplet | -ld)
        list_droplets
        ;;
--regions | -lr)
        list_regions
        ;;
--help | -h | *)
        clear
        app_name=$(basename $0)
        echo "$app_name Programmatically get information about your account using Digital Oceans API. "
        echo ""
       
        echo ""
        echo "Usage:"
        echo "$app_name -account | -domain | -keys | -ld | -lr | -h --help"
        echo ""
        echo "Options:"
        echo -e "    --help -h            \tShow this help screen"
        echo -e "    -account             \tShow account information"
        echo -e "    -domain              \tShow your domains that are managed by Digital Ocean"
        echo -e "    -keys                \tShow all your SSH keys"
        echo -e "    --droplet -ld        \tList your droplets"
        echo -e "    --regions -lr        \tList regions available within Digital Ocean"
        ;;
esac