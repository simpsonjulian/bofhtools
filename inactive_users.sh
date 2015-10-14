#!/bin/bash

ONE_WEEK=604800
TWO_WEEKS=$(( $ONE_WEEK * 2 ))

set +x
./gam.py print users | egrep -v '^Got |^Email|primaryEmail' | while read email; do
  last_login=`./gam.py info user $email| grep 'Last login time' | cut -f2 -d':' `
  current_date=`date +%s`
  if [ $last_login == 'Never' ]; then
    echo $email $last_login
  else
    last_login_date=`date -jf "%FT%H" $last_login +%s `
    diff=$(( $current_date - $last_login_date ))
    if [ $diff -gt $TWO_WEEKS ]; then
      echo $email $last_login
    fi
  fi
done
