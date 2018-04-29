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
  	git clone --depth=1 $ansible_repo
	echo ""
  else
  	git clone --depth=1 $ansible_repo
	echo ""
  fi

  if [ -d shell_scripts ]; then
	rm -rf shell_scripts
	git clone --depth=1 $shell_script_repo
	echo ""
  else
	git clone --depth=1 $shell_script_repo
	echo ""
  fi

  if [ -d cloud_init ]; then
	rm -rf cloud_init
	git clone --depth=1 $cloud_init_repo
	echo ""
  else
	git clone --depth=1 $cloud_init_repo
	echo ""
  fi
}

clean(){
	if [ -d shell_scripts ]; then
		rm -rf shell_scripts
	fi
	if [ -d ansible ]; then
		rm -rf ansible
		if [ -f inventory ];then
			rm inventory
		fi
	fi
	if [ -d cloud_init ]; then
		rm -rf cloud_init
	fi
	if [ -f terraform.tfstate ];then
		rm -rf terraform*
		rm -rf .terraform
	fi
}

plan(){
 clone
 init
 $tf plan $cred 
}

apply(){
 clone
 init
 $tf apply -auto-approve $cred
}

case $1 in
-i | init)
	$tf init
;;
clone)
	clone
;;
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
destroy)
	$tf destroy $cred
	clean
;;
clean)
	clean
;;
-f|fmt)
	$tf fmt
;;
-v|validate)
	$tf validate
;;
*)
	echo "$0 [options]"
	echo ""
	echo "Options are: clone | plan | apply| show| list | destroy | fmt | validata"
	echo ""
;;
esac
