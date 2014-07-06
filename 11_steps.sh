#!/bin/bash

# How to remove a Google Apps user gracefully
# http://blog.backupify.com/2014/01/22/the-11-steps-to-take-before-you-delete-a-user-from-a-google-apps-domain/

die() {
  echo $1
  exit 1
}

[ $# -ge 2 ] || die "Usage: $0 <user> <executor> <action>"

user=$1
executor=$2
action=$3

gam() {
  ./gam.py $@
}

change_password() {
  local password=$(openssl rand -base64 12)
  local user=$1
  gam update user $user password "$password"
  echo "Write this down: $user: $password"
}

take_backup() {
  die "Manual Step: backup the user"
}

out_of_office() {
  gam user $user vacation on subject "$first_name $last_name has left $company --- " message "$first_name $last_name no longer works at $company.

Please direct all future correspondence to ${executor_email}. Thanks."
}

delegate_email() {
  local user=$1
  local executor_email=$2
  gam user $user delegate to $executor_email
}

transfer_docs() {
  local user=$1
  local executor=$2
  die "Manual Step: Transfer docs from ${} to ${}" 
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

properties_file='bamgam.properties'
[ -f $properties_file ] || die "I need a properties file called ${properties_file}"
. $properties_file
executor_email="${executor}@${domain}"
user_email="$user@${domain}"

# Audit user info 
user_info='/tmp/bamgam.$$' || die "Can't find info on $user"
wc -l blah blah

./gam.py info user $user > $user_info
first_name=$(cat $user_info  | grep 'First Name'| cut -f 2 -d ':')
last_name=$(cat  $user_info  | grep 'Last Name' | cut -f 2 -d ':')


set -e
change_password
out_of_office
delegate_email

take_backup
transfer_docs

#add_contacts_to_directory
#delegate_access_to_calendars
#audit_non_google_services
if [ $action == 'delete' ]; then
  # Delete user account
  delete_account $user
  redirect_mail_to_group $user_email $executor_email
fi
