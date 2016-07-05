#!/bin/bash
. env.sh
python ./lib/python2.7/site-packages/trolly/authorise.py -a $TRELLO_API_KEY "Server Token" never
