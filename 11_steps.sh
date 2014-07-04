#!/bin/bash

# How to remove a Google Apps user gracefully\
# http://blog.backupify.com/2014/01/22/the-11-steps-to-take-before-you-delete-a-user-from-a-google-apps-domain/

die() {
  echo $1
  exit 1
}

[ $# -ge 2 ] || die "Usage: $0 <user> <executor>"

user=$1
password=$(openssl rand -base64 12)
executor=$2
gam='./gam.py'
properties_file='bamgam.properties'
[ -f $properties_file ] || die "I need a properties file called ${properties_file}"
. $properties_file
executor_email="${executor}@${domain}"
user_email="$user@${domain}"

# Audit user info 
user_info='/tmp/bamgam.$$'
./gam.py info user $user > $user_info
first_name=$(cat $user_info  | grep 'First Name'| cut -f 2 -d ':')
last_name=$(cat  $user_info  | grep 'Last Name' | cut -f 2 -d ':')

# Change the password, keep it
./gam.py update user $user password "$password"

echo "$user: $password"
# Take backup

# Choose executor
# Autoresponder

./gam.py user $user vacation on subject "$first_name $last_name has left $company --- " message "$first_name $last_name no longer works at $company.

Please direct all future correspondence to ${executor_email}. Thanks."

# Delegate Email Access
$gam user $user delegate to $executor_email

# Transfer Docs
echo "Manual Step" 
exit 1

# Add contacts to the apps directory
# delegate access to calenders
# transfer ownership of any groups
# Audit non-core services
# Wait 90 days
if [ $4 == 'delete' ]; then
  # Delete user account
  echo "Going to delete $user!"
  echo "Sleeping for 30"
  sleep 30
  $gam delete user $user
  # Create Group with same address as deleted user
  $gam create group $user_email
  $gam update group $user_email add manager user $executor_email
fi
