#!/bin/bash

set=+x

cred="-var "do_token=${DO_PAT}""
tf=$(which terraform)
ansible_repo="https://github.com/maxwayne-mills/ansible.git"
shell_script_repo="https://github.com/maxwayne-mills/shell_scripts.git"
cloud_init_repo="https://github.com/maxwayne-mills/cloud_init.git"


init(){
 echo ""
 echo "Initializing provider"
 echo ""
 $tf init
  
 echo "Formatting files"
 echo ""
 $tf fmt
 echo ""
 echo "Validating files"
 echo ""
 $tf validate
}

clone(){
  if [ -d ansible ]; then
	rm -rf ansible
  	git clone -depth=1 $ansible_repo
  else
  	git clone -depth=1 $ansible_repo
  fi

  if [ -d shell_scripts ]; then
	rm -rf shell_scripts
	git clone --depth=1 $shell_script_repo
  else
	git clone --depth=1 $shell_script_repo
  fi

  if [ -d cloud_init ]; then
	rm -rf cloud_init
	git clone --depth= $cloud_init_repo
  else
	git clone --depth= $cloud_init_repo
  fi
}
plan(){
 init
 $tf plan $cred 
}

apply(){
 init
 clone
 $tf apply
}

case $1 in
plan)
	plan
;;
apply)
	apply
;;
show)
	$tf show
;;
list)
	$tf state list
;;
*)
	echo "Nothing entered"
;;
esac
