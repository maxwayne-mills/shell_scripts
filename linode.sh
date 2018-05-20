#!/usr/bin/env bash

verify_curl=$(which curl)
lci=$(which linode)

# Get the  token information from local file
TOKEN="$(cat ~/.linode-cli | grep -i token | sort -u | awk 'BEGIN { FS = "=" };{print $2}' | sed 's/ //g')"

if [ -f ~/.linode-cli ]; then
        echo
else
        echo "Linode-cli configuration file not found within $(whoami) home directory"
fi

create (){
curl -H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-X POST -d '{
        "swap_size": 512,
        "image": "linode/debian9",
        "root_pass": "Tr33oflife!",
        "authorized_keys": [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDN+JBPWHbViSin0QhZwllakXSTjE+6memHlokEL4hKbIQIyETKv//iZVUCE1lDnc0uE73cDKS8HVHR4S3N2WWHzeuStWIDnirOHE4SW3GgeQfu1H1DikHf7E+PT8qJhQWtAYzEJyFf4vgPn/KuNhJFRWXmR3zK3gACZWP1ON9fymoBzi5MG9YM44JJnGoYM3CX7Aav/1DwIR5Sc1jRJ6uxJTsH1qv7EC81hjmvMAT+DscD5yx5yU28VJ3LM0p2RrRDaZcjXGYviXUoXufZl9MbKrsya9nRrL4wiUgECrgbkYy3XJNN4LYZT9oeRqqzyU3H9N33of7KhcR78fPbt6dxq56f+gSNHOsImTLPsbfKMoRg01j1Pi3ambAdBaA9XLKfCn4rCNXVmjJ8CGuYCf2SW8ur9DG/v43PVeZerhdQJ6Jgg6nilJoqUBA38B6cFFuyNkK1DH8wRq2b55khEEKCRUA3jcvz44N7VD4SJfWr9vDz0xlpUgKTMijDg3/5RHmS6yGfE9fw0CHucRMF1z6gYjyyjpPkDcceobnS+370efsF/qfKXao4bfkHm+vUSfZlz5KfuLjggYjZzmKTTM50oJyrHgcOpxUvqJH2OWKiTHX8bVdlh/amzrALqr1zCg0amMulKmU4K4ucGUwWUF/m6aMgwA42HtAHSEc35oF3GQ== oss@cmills-Kudu-Pro"
        ],
        "booted": true,
        "label": "srv1",
        "type": "g5-nanode-1",
        "region": "us-east",
        "group": "Linode-Group"
}' \
https://api.linode.com/v4/linode/instances
}

delete (){
# obtain Node ID
id=$(linode-cli --text --no-headers linodes list | awk '{print $1}')

curl -H "Authorization: Bearer $TOKEN" \
-X DELETE \
https://api.linode.com/v4/linode/instances/$id
}

account(){
        linode-cli account view
}

list(){
        linode-cli linodes list
}

case $1 in
account)
        account
        ;;
check)
        account
        list
        ;;
list)
        list
        ;;

create)
        create
        ;;
delete)
        delete
        ;;
*) 
        echo "$0  account | check | list | create | delete"
        ;;
esac