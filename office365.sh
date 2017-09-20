#!/bin/bash

. env.sh
export O365_APP_ID O365_APP_SECRET O365_APP_TENANT_ID
./bin/python office365.py
