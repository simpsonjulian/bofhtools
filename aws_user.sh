#!/bin/bash
action=$1
email=$2

usage() {
  echo "Usage: $0 <create|delete> email"
}

password=`pwgen -Byn 15 1`
if [ -z "$email" ]; then
  usage
  exit 1
fi

create() {
  local email=$1
  aws iam create-user --user-name $email
  aws iam add-user-to-group --group-name DevTeam --user-name $email
  aws iam create-access-key --user-name $email --output text
  aws iam create-login-profile --user-name $email --password $password
  echo $password
}

delete() {
  local email=$1
  aws --output=text iam list-groups-for-user --user-name $email | awk '{print $5}' | while read group; do
    aws iam remove-user-from-group --user-name $email --group-name $group
  done
  aws --output=text iam list-access-keys --user $email | awk '{print $2}' | while read key; do 
    aws iam delete-access-key --access-key-id $key --user-name $email
  done
  aws iam delete-login-profile --user-name $email
  aws iam delete-user --user-name $email
}

if [ $action == 'create' ]; then
  create $email
elif [ $action == 'delete' ]; then
  delete $email
else
  usage
fi
