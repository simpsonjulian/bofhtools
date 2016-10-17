#!/bin/bash

remove() {
  email=$1
  exec_email=$2

  file_name="/tmp/dropbox_remove_user.json"
  cat <<-EOF > $file_name
  {
    "user": {
        ".tag": "email",
        "email": "$email"
    },
    "wipe_data": true,
    "transfer_dest_id": {
        ".tag": "email",
        "email": "$exec_email"
    },
    "transfer_admin_id": {
        ".tag": "email",
        "email": "$SYSTEMS_ADMIN"
    }
  }
EOF
  curl -svfX POST https://api.dropboxapi.com/2/team/members/remove \
    --header "Authorization: Bearer $DROPBOX_APP_TOKEN" \
    --header "Content-Type: application/json" \
    --data @$file_name
  rm $file_name
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


  curl -fsX POST https://api.dropbox.com/1/team/members/add \
    --header "Authorization: Bearer $DROPBOX_APP_TOKEN" \
    --header "Content-Type: application/json" \
    --data @$file_name || die "Something went wrong talking to Dropbox"
  rm $file_name
}

usage() {
  echo "Usage: $0 add <user email> [firstname] [lastname]
       $0 remove <user email> <executor email>"
}

if [ $# -lt 2 ]; then
  usage
  exit 1
fi

action=$1
shift
email=$1
shift
echo $action

. env.sh

if [ $action == 'add' ]; then
  fname=$1
  lname=$2
  add $email $fname $lname
elif [ $action == 'remove' ]; then
  executor=$1
  remove $email $executor
else
  usage
fi
