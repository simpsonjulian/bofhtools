#!/bin/bash

. env.sh
export CITRIX_USERNAME CITRIX_PASSWORD CITRIX_CONSUMER_KEY CITRIX_LICENSE_KEY \
  CITRIX_GROUP_KEY
./bin/python gotomeeting.py $@
