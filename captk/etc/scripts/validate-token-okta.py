#!/bin/python3

#import okta-jwt-verifier
import requests, os, sys

introspect_url = os.environ['INTROSPECT_URL']
client_id = os.environ['CLIENT_ID']
client_secret = os.environ['CLIENT_SECRET']
access_token = sys.argv[1]
user_id = os.environ['USER_ID']

# Exit with code 1 if any steps fail

if len(sys.argv) < 2:
    print("No token was provided.")
    exit(1)

payload = {'token': access_token, 'token_type_hint': 'access_token'}

r = requests.post(introspect_url, data=payload,
                  auth=(client_id, client_secret))

response = r.json()
print(response)

if response['active'] != True:
    print("Token isn't active!")
    exit(1)
# Succeed if the USER_ID var set at container run-time is either the subject or UID
if ((response['sub'] == user_id) or (response['uid'] == user_id)):
    print("Token is active and subject matches!")
    exit(0)
else:
    print("Token is active, but subject doesn't match!")
    exit(1)
