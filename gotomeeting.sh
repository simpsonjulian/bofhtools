#!/bin/bash

. env.sh
export CITRIX_USERNAME
export CITRIX_PASSWORD
export CITRIX_CONSUMER_KEY
./bin/python gotomeeting.py $@
