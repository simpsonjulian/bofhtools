#!/bin/bash

# Tells you if files haven't migrated over properly
# Input: a CSV file from GAM: see file_diff.sh
# Output: CSV to stdout of owner, title and ID

input=$1
olddomain=$2
newdomain=$3
[ $# -eq 3 ] || exit 1
shares_dir="$newdomain/shares"

debug='ue'
gam() {
  [ -n "$debug" ] && echo "Command is gam.py $@" 1>&2
  ./gam.py $@
}

guess_email_address() {
  name=$1
  domain=$2
  echo "$(echo $name | sed -e 's/ö/o/g' -e's/é/e/g' | awk '{print tolower($0)}')@$domain"
}

add_permission() {
  local sharer=$1
  local id=$2
  local name=$3
  local role=$4
  local kind=$5
  local withlink=$6
  if [ -n "$withlink"] ;then 
    args='withlink'
  else
    args=''
  fi
  gam user $sharer add drivefileacl $id $type $name role $role $args
}

remove_permission() {
  local sharer=$1
  local id=$2
  local collaborator=$3
  gam user $sharer delete drivefileacl $id $collaborator
}

fix_old_shares() {
  local user=$1
  local id=$2
  local olddomain=$3
  local newdomain=$4
  IFS=' '
  shares_file="$shares_dir/$id"

  ./get_shares.rb $shares_file | while read name domain role type entity email linkonly; do
    [ -n "$debug" ] && echo "$name $domain $role $type $entity $email $linkonly"

    if [[ $domain == *$olddomain* ]]; then

      case $type in
      user|group)
        collaborator=$(guess_email_address $name $newdomain)
        ;;
      domain)
        collaborator=$newdomain
        ;;
      *)
        echo "Unknown type $type"
        exit 1
        ;;
      esac
      # if it looks like there's a thing of that type: skip it
      ./get_shares.rb $shares_file | grep $type | grep  $name | grep $newdomain|| \
      add_permission $user $id $collaborator $role $type $linkonly
      remove_permission $user $id $entity
    fi
  done
  IFS=','
}

mkdir -p $shares_dir
IFS=','
while read user title id; do
  file_info="$shares_dir/$id"
  gam user $user show drivefileacl $id > $file_info
  if grep -q $olddomain $file_info;then 
   fix_old_shares $user $id $olddomain $newdomain
  sleep 10
  fi 
  sleep 5
done < ${input}
