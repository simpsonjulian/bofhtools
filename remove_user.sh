#!/bin/bash

# How to remove a Google Apps user gracefully
# http://blog.backupify.com/2014/01/22/the-11-steps-to-take-before-you-delete-a-user-from-a-google-apps-domain/

# validate both users


die() {
  echo "$1"
  exit 1
}


gam() {
  $GAM_BINARY $@
}

noadmin() {
  local user=$1
  if [ -z "$NOT_SUPER_ADMIN" ]; then
    gam update user $user admin off
  else
    echo "Not removing admin privs: you probably don't have super admin"
  fi
}

create_takeout() {
  local user=$1
  echo "Manual Step: disable 2-Step Authentication"
  die "Manual Step: log in as the user and invoke Google Takeout on all their stuff"
}

cloud_pages() {
  local user=$1
  die "Go run the Cloud Pages decomissioning process"
}

copy_takeout() {
  set -x
  local user=$1
  gam user $user show filelist id title | egrep 'takeout|All mail Including Spam' | awk -F ',' '{print $1,$2,$3,$4}' | while read owner id filename; do
    echo $owner
    echo $filename
    echo $id
    echo $url
    gam user $user add drivefileacl $id user $SYSTEMS_ADMIN role reader
    gam user $user update drivefileacl $id $SYSTEMS_ADMIN role owner
    gam user $user update drivefile id $id newfilename "${user}-${filename// /-}"
  done
}

remove_from_groups() {
  local user=$1
  gam info user $user |grep -A50 Groups | egrep -v 'Groups|Licenses|Google-Apps' | awk 'NF>1{print $NF}' | sed 's/[<>]//g' | while read email; do
    gam update group $email remove user $user
  done
}

change_password() {
  password=$(openssl rand -base64 12)
  local user=$1
  gam update user $user password "$password"
  echo "Write this down: $user: $password"
}

out_of_office() {
  local user=$1
  local first_name=$2
  local last_name=$3
  local executor_email=$4
  local company=$5
  $GAM_EXECUTABLE user $user vacation on subject "$first_name $last_name has left $company ---" message "Hello\n$first_name $last_name no longer works at $company.\n\nPlease direct all future correspondence to ${executor_email}. Thanks."
}

delegate_email() {
  local user=$1
  local executor=$2
  if [ -z "$NOT_SUPER_ADMIN" ]; then
    gam user $user delegate to $executor
  else
    echo "Not delegating email as you're probably not a Super Admin"
  fi

}


redirect_mail_to_group() {
  local user_email=$1
  local executor_email=$2
  gam create group $user_email
  gam update group $user_email add manager user $executor_email
}

two_step_exclusion() {
  local user_email=$1
  gam update group $TWO_STEP_EXCEPTION_GROUP add member $user_email
}

show_executor_email() {
  local user_email="$1@${domain}"
  local executor_email="$2@${domain}"
  local password=$3

message="Hi there,

I’ve started the process of decommissioning the account ${user_email}@${domain}.  You have been identified as someone who might need access to their digital belongings.  Their password is now $password.

You should also be able to gain access to their account through delegated email (from the Gmail app).[1]

We'll automatically delete this account in 3 months.  You’ll optionally be able to see email that is sent to them after their account is deleted.


[1] Go to the Gmail app, click on your avatar on the top right.  Select the user's account or click 'add account'.
" 
  ./send_email.sh $executor_email "$user_email" "$message"
}

usage="Usage: $0 <user name> prep|harvest|followup <executor>"
[ $# -ge 3 ] || die "$usage"

user=$1
action=$2
executor=$3

properties_file='env.sh'
[ -f $properties_file ] || die "I need a properties file called ${properties_file}"
. $properties_file
executor_email="${executor}@${domain}"
user_email="$user@${domain}"

user_info="/tmp/bamgam.$$" || die "Can't find info on $user"

gam info user $user > $user_info
first_name=$(cat $user_info  | grep 'First Name'| cut -f 2 -d ':')
last_name=$(cat  $user_info  | grep 'Last Name' | cut -f 2 -d ':')

set -e
if [ $action == 'prep' ]; then
  gam user $user deprovision
  change_password $user
  noadmin $user
  out_of_office $user $first_name $last_name $executor_email "$company"
  delegate_email $user $executor
  show_executor_email $user $executor $password
  remove_from_groups $user
  two_step_exclusion $user
  create_takeout $user
elif [ $action == 'harvest' ]; then
  copy_takeout $user
  cloud_pages $user
elif [ $action == 'followup' ]; then
  redirect_mail_to_group $user_email $executor_email
else
  die $usage
fi
