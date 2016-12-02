#!/bin/bash

action=$1
email=$2

die() {
  echo $@
  exit 1
}

[ $# -eq 2 ] || die "Usage: $0 <add|remove> email"

. env.sh

if [ $action == 'add' ]; then
  curl -sX POST -d email=$email -d token=$SLACK_TOKEN https://${SLACK_HOST}.slack.com/api/users.admin.invite
elif [ $action == 'remove' ]; then
  echo "Manual Step: remove this account from Slack"
elif [ $action == 'audit' ]; then
  curl -s https://${SLACK_HOST}.slack.com/api/users.list?token=${SLACK_TOKEN} | jq -c '.members[] | {"deleted":.deleted, "real_name": .profile.real_name , "email": .profile.email}' 
fi
