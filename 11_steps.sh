#!/bin/bash

# How to remove a Google Apps user gracefully
# http://blog.backupify.com/2014/01/22/the-11-steps-to-take-before-you-delete-a-user-from-a-google-apps-domain/

die() {
  echo $1
  exit 1
}


gam() {
  ./gam.py $@
}

change_password() {
  password=$(openssl rand -base64 12)
  local user=$1
  gam update user $user password "$password"
  echo "Write this down: $user: $password"
}

take_backup() {
  local user=$1
  die "Manual Step: backup the user $user"
}

out_of_office() {
  local user=$1
  local first_name=$2
  local last_name=$3
  local executor_email=$4
  local company=$5
  ./gam.py user $user vacation on subject "$first_name $last_name has left $company ---" message "Hello\n$first_name $last_name no longer works at $company.\n\nPlease direct all future correspondence to ${executor_email}. Thanks."
}

delegate_email() {
  local user=$1
  local executor_email=$2
  gam user $user delegate to $executor_email
}

transfer_docs() {
  local user=$1
  local executor=$2
  docs_count=$(gam user $user show filelist| grep -v Owner | wc -l )
  echo $docs_count
  if [ $docs_count != 0 ]; then
    die "Manual Step: Transfer docs from ${user} to ${executor}.  Then restart me "
  fi
}

delete_account() {
  echo "Going to delete $user!"
  echo "Sleeping for 30"
  sleep 30
  gam delete user $user
}

redirect_mail_to_group() {
  # Create Group with same address as deleted user
  local user_email=$1
  local executor_email=$2
  gam create group $user_email
  gam update group $user_email add manager user $executor_email
}

show_executor_email() {
  local user_email=$1
  local executor_email=$2
  local password=$3

  cat <<EOF
Hi there,

I’ve started the process of decommissioning the account $user_email, and you have been nominated as the person who might need things from their Google Apps account.  Their password is now $password.

You should also be able to gain access to their account through delegated email (from the Gmail app).[1]

When you’re sure that there’s nothing of value left in their email, let me know and I’ll remove their account.  You’ll optionally be able to see email that is sent to them after their account is deleted.

Best

Julian.


[1] Go to the Gmail app, click on your avatar on the top right.  Select the user's account or click 'add account'.
EOF
  
}

[ $# -ge 3 ] || die "Usage: $0 <user> <executor> <action>"

user=$1
executor=$2
action=$3

properties_file='bamgam.properties'
[ -f $properties_file ] || die "I need a properties file called ${properties_file}"
. $properties_file
executor_email="${executor}@${domain}"
user_email="$user@${domain}"

# Audit user info 
user_info="/tmp/bamgam.$$" || die "Can't find info on $user"

./gam.py info user $user > $user_info
first_name=$(cat $user_info  | grep 'First Name'| cut -f 2 -d ':')
last_name=$(cat  $user_info  | grep 'Last Name' | cut -f 2 -d ':')


set -e
if [ $action == 'prep' ]; then
  change_password $user
  out_of_office $user $first_name $last_name $executor_email "$company"
  delegate_email $user $executor_email
  transfer_docs $user $executor
  show_executor_email $user $executor $password
  take_backup $user
fi

#add_contacts_to_directory
#delegate_access_to_calendars
#audit_non_google_services
if [ $action == 'delete' ]; then
  # Delete user account
  delete_account $user
  redirect_mail_to_group $user_email $executor_email
fi
