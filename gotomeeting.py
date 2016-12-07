from datetime import datetime, timedelta
from os import environ
from sys import argv

import requests

API_HOST = 'https://api.citrixonline.com'

DEFAULT_HEADERS = {"Accept": "application/json", "Content-type": "application/x-www-form-urlencoded"}
ORGANIZERS = API_HOST + '/G2M/rest/organizers'


def get_access_token(headers):
    data = dict(grant_type='password', user_id=environ.get('CITRIX_USERNAME'), password=environ.get('CITRIX_PASSWORD'),
                client_id=environ.get('CITRIX_CONSUMER_KEY'))
    response = requests.post(API_HOST + "/oauth/access_token", data, headers=headers).json()
    return response['access_token'], response['account_key']


def handle_encoding(response):
    if response:
        return response.encode('utf8')
    else:
        return response


def get_meetings_for_user(id, headers):
    end_date = datetime.now().isoformat()
    start_date = (datetime.now() + timedelta(weeks=-52)).isoformat()

    response = requests.get('{}/G2M/rest/organizers/{}/historicalMeetings'.format(API_HOST, id),
                            dict(startDate=start_date, endDate=end_date), headers=headers).json()
    return len(response)


def usage(script):
    print "Usage: {}: 'audit|add|remove' <args> ".format(script)
    exit(1)


if len(argv) == 2:
    script, action = argv
elif len(argv) == 5:
    script, action, email, first_name, last_name = argv
elif len(argv) == 3:
    script, action, email = argv
else:
    usage(argv[0])


def configure_authorisation(api):
    headers = DEFAULT_HEADERS
    access_token, account_key = get_access_token(headers)

    if api == 'rest':
        headers['Authorization'] = access_token
    elif api == 'restv1':
        headers['Authorization'] = "OAuth oauth_token={}".format(access_token)
    else:
        print "I don't know about that API"
        raise RuntimeError
    return headers, account_key


def audit_users():
    headers, account_key_ = configure_authorisation('rest')
    response = requests.get(ORGANIZERS, {}, headers=headers)
    response.raise_for_status()
    users = response.json()
    print "{} users found:".format(len(users))
    for user in users:
        product = user['products'][0]
        email = user['email']
        count = get_meetings_for_user(user['organizerKey'], headers)

        print(
            "{:35} {:20} {:10} {:7} {}".format(email, " ".join([user['firstName'], user['lastName']]),
                                               user['groupName'],
                                               product, count))


def add_user(email, first_name, last_name):
    global headers
    headers, account_key = configure_authorisation('restv1')
    payload = {
        "users": [{"email": email,
                   "firstName": first_name,
                   "lastName": last_name,
                   "locale": "en_US"}],

        "adminRoles": [],
        "managedGroupKeys": [
        ],
        "licenseKeys": [
            environ.get('CITRIX_LICENSE_KEY')
        ],
        "groupKey": environ.get('CITRIX_GROUP_KEY'),
        "emailContent": {
            "subject": "Welcome to GoToMeeting",
            "text": "You've been added by "
        }
    }
    url = v1_user_url(account_key)
    response = requests.post(url, json=payload, headers=headers)
    if response.json()[0].has_key('key'):
        print 'User added'
    else:
        print "Something went wrong"
        raise RuntimeError


def v1_user_url(account_key, user=None):
    url = '{}/admin/rest/v1/accounts/{}/users'.format(API_HOST, account_key)
    if user:
        url += '/{}'.format(user)

    return url


if action == 'audit':
    audit_users()
elif action == 'add':
    print 'adding'
    add_user(email, first_name, last_name)

elif action == 'remove':
    headers, account_key = configure_authorisation('rest')
    response = requests.get(v1_user_url(account_key), headers=headers)

    user = [user for user in response.json()['results'] if user['email'] == email]
    user_key = user[0]['key']
    response = requests.delete(v1_user_url(account_key, user_key), headers=headers)
    response.raise_for_status()
else:
    usage(script)
