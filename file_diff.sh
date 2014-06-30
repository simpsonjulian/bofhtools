#!/bin/bash

# Copyright (C) Neo Technology, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Julian Simpson <julian@neotechnology.com>, May 2014

# You need to have permissions set up to log into the domain via GAM

# Outputs a report of files that haven't migrated over

# Excludes trashed files
# Not yet done: folders

DATE=$(date +%F)

find_missing_files() {
  report_file="missing-${DATE}.txt"
  > $report_file
  local souce_domain=$1
  local dest_domain=$2
  IFS=','
  sed "s/${source_domain}/${dest_domain}/" ${source_domain}.${DATE}.csv | while read email shared title id alink; do

    matches=$(grep $email ${dest_domain}.${DATE}.csv | grep "$title"| wc -l| tr -d ' ')

    if [ $matches == 0 ]; then
      echo "$email,$title,$shared,$id" >> $report_file
    fi
  done 
  IFS=$OIFS
  count=$(wc -l < $report_file | tr -d ' ')
  echo "Have a look at ${report_file} for ${count} missing files"
}

setup_gam_files() {
  local domain=$1
  for file in oauth2.txt gamcache client_secrets.json oauth2service.json oauth2service.p12; do
    ln -nfs $domain/$file $file
  done
}

render_report() {
  local domain=$1
  local report="${domain}.${DATE}.csv"
  mkdir -p $domain

  if [ ! -f "$report" ]; then
    setup_gam_files $domain
    ./gam.py all users show filelist id shared query "trashed = false and mimeType != 'application/vnd.google-apps.folder'" > ${report}
  fi
  cut -d',' -f 1,3 $report > ${domain}.cut
}

cleanup() {
  rm *.cut
}

[ $# -eq 2 ] || exit 1
source_domain=$1
dest_domain=$2

render_report $source_domain
render_report $dest_domain
find_missing_files $source_domain $dest_domain
cleanup
