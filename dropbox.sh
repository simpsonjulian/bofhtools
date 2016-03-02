#!/bin/bash

remove() {
  curl -X POST https://api.dropboxapi.com/2/team/members/remove \
    --header "Authorization: Bearer <get access token>" \
    --header "Content-Type: application/json" \
    --data "{\"user\": {\".tag\": \"team_member_id\",\"team_member_id\": \"dbmid:efgh5678\"},\"wipe_data\": true,\"transfer_dest_id\": {\".tag\": \"team_member_id\",\"team_member_id\": \"dbmid:efgh5678\"},\"transfer_admin_id\": {\".tag\": \"team_member_id\",\"team_member_id\": \"dbmid:efgh5678\"}}"
}

body() {
  local email=$1
  local fname=$2
  local lname=$3
  local file_name=$4
  cat <<-EOF > $file_name
  {
  "member_email": "${email}",
  "member_given_name": "${fname}",
  "member_surname": "${lname}",
  "send_welcome_email": true
  }
EOF
}

add() {
  local email=$1
  local fname=$2
  local lname=$3

  file_name=/tmp/dropbox_add_user.json
  body $email $fname $lname $file_name

  curl -X POST https://api.dropbox.com/1/team/members/add \
    --header "Authorization: Bearer $DROPBOX_APP_TOKEN" \
    --header "Content-Type: application/json" \
    --data @$file_name 
}

usage() {
  echo "Usage: $0 <add|remove> <email> [firstname] [lastname]"
}

action=$1
email=$2
fname=$3
lname=$4

if [ $# -lt 2 ]; then
  usage
  exit 1
fi

. env.sh

if [ $action == 'add' ]; then
  add $email $fname $lname
elif [ $action == 'remove' ]; then
  remove $email
else
  usage
fi
