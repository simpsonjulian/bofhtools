#!/bin/bash

# Tells you if files haven't migrated over properly
# Input: a CSV file from GAM: see file_diff.sh
# Output: CSV to stdout of owner, title and ID
input=$1
newdomain=$2
olddomain=$3
[ $# -eq 3 ] || exit 1

shares_dir="$newdomain/shares"

gam() {
  echo "Command is gam $@"
  ./gam.py $@
}

add_permission_to_user() {
  local sharer=$1
  local id=$2
  local collaborator=$3
  local role=$4
  local withlink=$5
  if [ -n "$withlink"] ;then 
    args='withlink'
  else
    args=''
  fi
  gam user $sharer add drivefileacl $id user $collaborator role $role $args

}

add_permission_to_domain() {
  local sharer=$1
  local id=$2
  local domain=$3
  local role=$4
  local withlink=$5
  if [ -n "$withlink"] ;then 
    args='withlink'
  else
    args=''
  fi
  gam user $sharer add drivefileacl $id domain $domain role $role $args
}

add_permission_to_group() {
  local sharer=$1
  local id=$2
  local group=$3
  local role=$4
  local withlink=$5
  if [ -n "$withlink"] ;then 
    args='withlink'
  else
    args=''
  fi
  gam user $sharer add drivefileacl $id group $group@neotechnology.com role $role $args
}
# squash?
remove_permission_from_user() {
  local sharer=$1
  local id=$2
  local collaborator=$3
  gam user $sharer delete drivefileacl $id $collaborator
}

remove_permission_from_group() {
  local sharer=$1
  local id=$2
  local group=$3
  gam user $sharer delete drivefileacl $id $group
}

remove_permission_from_domain() {
  local sharer=$1
  local id=$2
  local domain=$3
  gam user $sharer delete drivefileacl $id $domain
}

guess_email_address() {
  local name=$1
  local domain=$2
  prefix=$(echo $name | sed 's/ö/o/'| awk '{print tolower($0)}')
  echo "$prefix@$domain"
}

fix_old_shares() {
  local user=$1
  local id=$2
  local olddomain=$3
  local newdomain=$4
  IFS=' '
  shares_file="$shares_dir/$id"
  ./get_shares.rb $shares_file | while read name domain role type entity email linkonly; do

    if [[ $domain == *$olddomain* ]]; then
      echo "$name $domain $role $type $entity $email $linkonly"
      case $type in
      user)
        collaborator=$(guess_email_address $name $newdomain)
        add_permission_to_user $user $id $collaborator $role $linkonly
        #collaborator=$(guess_email_address $name $olddomain)
        remove_permission_from_user $user $id $entity
        ;;
      domain)
        add_permission_to_domain $user $id $entity $role $linkonly
        remove_permission_from_domain $user $id $entity
        ;;
      group)
        #group=$(guess_email_address $name $newdomain)
        echo "DEBUG: $role"
        add_permission_to_group $user $id $name $role $linkonly
        #group=$(guess_email_address $name $olddomain)
        remove_permission_from_group $user $id $entity
        ;;
      *)
        echo "Unknown type $type"
        exit 1
        ;;
      esac
    fi
  done
  IFS=','
}

mkdir -p $shares_dir
IFS=','
while read user shared title id url; do
  file_info="$shares_dir/$id"
  if [ "$shared" == 'True' ]; then
    ./gam.py  user $user show drivefileacl $id > $file_info
    if grep -q $olddomain $file_info;then 
     fix_old_shares $user $id $olddomain $newdomain
    fi 
  fi
done < ${input}
