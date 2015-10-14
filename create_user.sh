#!/bin/bash
die() {
  echo $@
  exit 1
}

firstname=$1
lastname=$2
domain=$3
group=$4

[ $# -eq 4 ] || die "Usage: $0 firstname lastname domain group (case insensitive)"

username=`echo ${firstname}.${lastname} | awk '{print tolower($0)}'`
password=`pwgen -Bs 11 1`
set -e
./gam.py create user $username firstname $firstname lastname $lastname password $password
./gam.py update group $group add member $username
echo "SEND THIS EMAIL"
cat <<EOM

$username@$domain

Hello $firstname,

Welcome to $domain!

Your login is $username@$domain
Your password is $password

You can login at https://www.google.com/work/apps/business/

EOM

echo "User $username@$domain created.  Send the email"
# when I've automated a way to send email securely, I'll add this
