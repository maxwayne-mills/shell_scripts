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
    $command "$content_type" -H "$auth"  "$account" | jq '.account | {status: .status, UUID: .uuid, email: .email, email_verified_status: .email_verified, Current_Satus: .status_message }'
}

get_domains(){
  domains="$url/domains"
  $command "$content_type" -H "$auth"  "$domains" | jq -S '.domains' | grep -i \"name\"
}

list_droplets(){
    list_droplets="$url/droplets"
    #$command "$content_type" -H "$auth"  "$list_droplets" | jq   # Display all fields
    #$command "$content_type" -H "$auth"  "$list_droplets" | jq -s '[.[] | [.droplets[].name]]' # Only display the droplet name
    $command "$content_type" -H "$auth"  "$list_droplets" | jq -s '[.[] | [.droplets[0,2].name]]'
}

list_regions(){
    list_regions="$url/regions"
    #$command "$content_type" -H "$auth"  "$list_regions" | jq '.regions | [.name]'
    #$command "$content_type" -H "$auth"  "$list_regions" | jq -s '[.[] | [.regions[0,1].slug]]'
    $command "$content_type" -H "$auth"  "$list_regions" | jq -s '[.[] | [.regions[0,1,2,3,4,5,6,7,8].slug]]'
}

list_images(){
        list_images="$url/images"
        $command "$content_type" -H "$auth" "$list_images" | jq -S
}

keys(){
    keys="$url/account/keys"
    $command "$content_type" -H "$auth" "$keys" | jq '.ssh_keys'
}

case $1 in

-account | -a)
        get_account_info
        ;;
-domain | -D)
        get_domains 
        ;;
-keys | -k)
        keys
        ;;
--droplet |-d)
        list_droplets
        ;;
--regions | -r)
        list_regions
        ;;
-images | -i)
        list_images
        ;;
-s | -status)
        clear
        echo "Account Information"
        echo ""
        get_account_info
        echo ""
        echo "Droplet Information"
        list_droplets
        echo ""
        echo "Domains"
        get_domains
        
        ;;
--help | -h | *)
        clear
        app_name=$(basename $0)
        echo "$app_name Programmatically get information about your account using Digital Oceans API. "
        echo ""
        echo "You are required to export your Digital ocean token prior to executing commands within this script"
        echo "export token=\"your_digital_ocean_token\""
       
        echo ""
        echo "Usage:"
        echo "$app_name [Options"]
        echo ""
        echo "Options:"
        echo -e "    --help -h           \tShow this help screen"
        echo -e "    -account -a         \tShow account information"
        echo -e "    -domain -D          \tShow your domains that are managed by Digital Ocean"
        echo -e "    -keys -k            \tShow all your SSH keys"
        echo -e "    -droplet -d         \tList your droplets"
        echo -e "    -regions -r         \tList regions available within Digital Ocean"
        echo -e "    -status -s          \tPrint Account Information"
        echo -e "     -images -i         \tPrint images"
        ;;
esac