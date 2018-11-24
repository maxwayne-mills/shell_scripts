#!/usr/bin/env bash
# Get information about droplets and Digital Ocean accessories and services using
# DIgita Ocean API

command="curl -X GET -H"
content_type="Content-Type: application/json"
token=putyourdigitaloceantokenhere
auth="Authorization: Bearer $token"

# Different commands
#payload="https://api.digitalocean.com/v2/images?page=1&per_page=1"
account="https://api.digitalocean.com/v2/account"
domains="https://api.digitalocean.com/v2/domains"
list_droplets="https://api.digitalocean.com/v2/droplets"
list_regions="https://api.digitalocean.com/v2/regions"


# Get account information
get_account_info(){
    $command "$content_type" -H "$auth"  "$account" | jq '.account.email,.account.status,.account.uuid'
}

get_domains(){
  curl -X GET -H "$content_type" -H "Authorization: Bearer $token"  "$domains" | jq  
}

list_droplets(){
    curl -X GET -H "$content_type" -H "Authorization: Bearer $token"  "$list_droplets" | jq 
}

list_regions(){
    curl -X GET -H "$content_type" -H "Authorization: Bearer $token"  "$list_regions" | jq
}


get_account_info