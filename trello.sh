#!/bin/bash

. env.sh
export TRELLO_API_KEY
export TRELLO_API_TOKEN
export TRELLO_ORG

action=$1
email=$2
full_name=$3
message="Hi ${full_name}

We use Trello for project management.  You've been added to our Trello organisation.

Please log on to Trello with your Google Apps account to find out more:

https://trello.com/
"

if [ "$action" == 'add' -o "$action" == 'remove' ]; then
  ./trello_user.py $action $email "$full_name"
else
  echo "Usage: $0 add <email>
   $0 remove <username>"
fi
