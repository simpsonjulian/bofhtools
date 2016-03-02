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
  curl -X POST -d email=$email -d token=$SLACK_TOKEN https://${SLACK_HOST}.slack.com/api/users.admin.invite
fi
