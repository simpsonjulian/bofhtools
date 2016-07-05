#!/usr/bin/python

import sys
from os import environ

import trolly
from trolly.trelloobject import TrelloObject

token = environ.get('TRELLO_API_TOKEN')
key = environ.get('TRELLO_API_KEY')
org_name = environ.get('TRELLO_ORG')
client = trolly.client.Client(key, token)
script, action, email, full_name = sys.argv

organization = [org for org in (client.get_organisations()) if org.name == org_name][0]
if action == 'add':
    print organization.add_member(email=email, fullname=full_name)
elif action == 'remove':
    org_json = client.fetch_json('/organizations/' + org_name + '/members', 'GET')
    member_id = [ member for member in org_json if member['username'] == email ][0]['id']
    if member_id:
        print organization.remove_member(member_id)
    else:
        print "Member not found"
else:
    raise NotImplemented
