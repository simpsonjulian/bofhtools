#!/bin/bash

ONE_WEEK=604800
TWO_WEEKS=$(( $ONE_WEEK * 2 ))
. env.sh

current_date=`date +%s`
IFS=','
$GAM_DIR/gam.py print users  LastLoginTime| egrep -v '^Got |^Email|primaryEmail' | while read email last_login; do
  if [ $last_login == 'Never' ]; then
    echo $email $last_login
  else
    last_login_date=`date -jf "%FT%H:%M:%S.000Z" $last_login +%s `
    diff=$(( $current_date - $last_login_date ))
    if [ $diff -gt $TWO_WEEKS ]; then
      echo $email $last_login
    fi
  fi
done
