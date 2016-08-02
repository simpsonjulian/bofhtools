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

def get_trello_id(email_address='julian.simpson@neotechnology.com'):
    return client.fetch_json('/search/members', query_params=dict(query=email_address))[0]['id']

if action == 'add':
    organization.add_member(email=email, fullname=full_name)
    print "{} added".format(email)
elif action == 'remove':
    member_id = get_trello_id(email)
    if member_id:
        print organization.remove_member(member_id)
        print "{} removed".format(email)
    else:
        print "Member not found"
else:
    raise NotImplemented
