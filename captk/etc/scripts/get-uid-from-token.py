#!/bin/python3

# This script takes UID claim (or the sub claim, as a fallback) from a token. This should only be called on tokens that have already been validated.

from okta_jwt_verifier import JWTVerifier
import requests, os, sys

if len(sys.argv) < 2:
    print("No token was provided.")
    exit(1)

#introspect_url = os.environ['OKTA_INTROSPECT_URL']
access_token = sys.argv[1]
client_id = os.environ['OKTA_CLIENT_ID']
#user_id = os.environ['OKTA_USER_ID']

user_ids = [] # List, so we can potentially allow multiple users. Right now, we only change it out to one

issuer_url = os.environ['OKTA_ISSUER_URL']
audience = os.environ['OKTA_AUDIENCE']

# Exit with code 1 if any steps fail

def get_uid_from_token():
    # return UID, or failing that, the subject claim (will be stored internally from other scripts)
    try:
        jwt_verifier = JWTVerifier(issuer_url, client_id, audience)
        headers, claims, signing_input, signature = jwt_verifier.parse_token(access_token)
        #print("Claims:")
        #pprint.pprint(claims)
        if ('uid' in claims):
            result = claims['uid']
        #elif (claims.has_key('sub')):
        #    result = claims['sub']
        else:
            # UID and SUB don't exist
            print("Claims don't contain UID or subject. Double-check the token.")
            raise ValueError("claims don't contain UID or subject. Verify the token.")
        return result
    except:
        # Something went wrong, return none
        print("Exception thrown during token parsing.")
        return None

this_token_identifier = get_uid_from_token()
if (this_token_identifier is None):
    exit(1)
# print to stdout so shell scripts can get the result
print(this_token_identifier)
