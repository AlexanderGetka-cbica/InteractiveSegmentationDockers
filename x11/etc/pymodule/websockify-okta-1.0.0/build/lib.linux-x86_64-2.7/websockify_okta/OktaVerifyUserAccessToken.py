import os, sys, json, requests
from websockify.token_plugins import BasePlugin

introspect_url = os.environ['INTROSPECT_URL']
client_id = os.environ['CLIENT_ID']
client_secret = os.environ['CLIENT_SECRET']
user_id = os.environ['USER_ID']

class OktaVerifyUserAccessToken(BasePlugin):
    def __init__(self, src):
        target = src.split(':')
        self.source = (target[0], target[1]) # host, port tuple

    def lookup(self, token):
        # return None if we fail, return the provided token-source otherwise. token-source is just destination host:port
        access_token = token
        payload = {'token': access_token, 'token_type_hint': 'access_token'}
        r = requests.post(introspect_url, data=payload, auth=(client_id, client_secret))
        response = r.json()
        if response['active'] != True:
            print("Token isn't active!")
            return None
        if response['uid'] == user_id:
            print("Token is active and subject matches!")
            return self.source
        else:
            print("Token is active, but subject doesn't match!")
            return None

