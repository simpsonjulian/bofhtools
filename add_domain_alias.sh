#!/bin/bash
email=$1
fullname=$2

if [ ! $# -eq 2 ]; then
  echo "Usage: $0 <email> <full name>"
  exit 1
fi

username=${email%@neotechnology.com}
new_email="$username@neo4j.com"
. env.sh

"${GAM_BINARY}" user "${username}" sendas "${new_email}" "${fullname}" replyto "${new_email}" default
