#!/usr/bin/python
import sys
from os import environ

import trolly

token = environ.get('TRELLO_API_TOKEN')
key = environ.get('TRELLO_API_KEY')
org_name = environ.get('TRELLO_ORG')

client = trolly.client.Client(key, token)

script, action, email, full_name = sys.argv

organization = [org for org in (client.get_organisations()) if org.name == org_name][0]
if action == 'add':
    print organization.add_member(email=email, fullname=full_name)
else:
    raise NotImplemented
    # need to get ID from email before I can run `remove_member`
