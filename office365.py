import webbrowser
from time import sleep
from os import environ

import requests

application_id = environ.get('O365_APP_ID')
secret = environ.get('O365_APP_SECRET')
tenant_id = environ.get('O365_APP_TENANT_ID')

headers = {'Content-type': 'application/json'}

payload = {'grant_type': 'client_credentials',
           'client_id': application_id,
           'client_secret': secret,
           # 'resource': 'https://graph.microsoft.com',
           'scope': 'https://graph.microsoft.com/.default'}
           # 'scope': 'User.ReadBasic.All User.Read.All User.ReadWrite.All Directory.Read.All Directory.ReadWrite.All Directory.AccessAsUser.All'}

login_url = 'https://login.microsoftonline.com/{}/oauth2/v2.0/token'.format(tenant_id)

def register(tenant_id, application_id):
    webbrowser.open_new_tab("https://login.microsoftonline.com/{}/adminconsent?client_id={}&state=12345&redirect_uri=http://localhost:5000/auth".format(
        tenant_id, application_id))

# register(tenant_id, application_id)
# sleep(30)
r = requests.post(login_url, data=payload)
response = r.json()
# print response
token = response['access_token']
r = requests.get('https://graph.microsoft.com/v1.0/me', headers={'Authorization': 'Bearer {}'.format(token)})
print r.text