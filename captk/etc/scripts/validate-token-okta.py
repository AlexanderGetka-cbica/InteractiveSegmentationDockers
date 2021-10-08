#!/bin/python3

from okta_jwt_verifier import JWTVerifier
import requests, os, sys, asyncio

#introspect_url = os.environ['OKTA_INTROSPECT_URL']
client_id = os.environ['OKTA_CLIENT_ID']
#client_secret = os.environ['OKTA_CLIENT_SECRET']
access_token = sys.argv[1]
user_id = os.environ['OKTA_USER_ID']
issuer_url = os.environ['OKTA_ISSUER_URL']
audience = os.environ['OKTA_AUDIENCE']

# Exit with code 1 if any steps fail

if len(sys.argv) < 2:
    print("No token was provided.")
    exit(1)

# Change to false to require user-specific authentication -- that is, the UID must match one passed in via OKTA_USER_ID env var.
ALLOW_ANY_VALID_USER = True

# Remote introspection -- requires CLIENT_SECRET environment variable and verifies with the Okta introspection endpoint
def remote_introspect():
    payload = {'token': access_token, 'token_type_hint': 'access_token'}

    r = requests.post(introspect_url, data=payload,
                 auth=(client_id, client_secret))

    response = r.json()
    print(response)

    if response['active'] != True:
        print("Token isn't active!")
        exit(1)
    # Succeed if the OKTA_USER_ID var set at container run-time is either the subject or UID
    if ((response['sub'] == user_id) or (response['uid'] == user_id)):
        print("Token is active and subject matches!")
        exit(0)
    else:
        print("Token is active, but subject doesn't match!")
        exit(1)
    return

# Local verification -- doesn't require any CLIENT_SECRET, but does need OKTA_AUDIENCE env_var (usually api://default)
async def token_verification_task():
    try:
        jwt_verifier = JWTVerifier(issuer_url, client_id, audience)
        headers, claims, signing_input, signature = jwt_verifier.parse_token(access_token)
        #print("Claims:")
        #pprint.pprint(claims)
        # Will throw exception if verification fails
        await jwt_verifier.verify_access_token(access_token)
        if (ALLOW_ANY_VALID_USER or (claims['uid'] == user_id)):
            # Success
            print("Verified claim UID matches.")
            return True
        else:
            # Failure -- UID mismatch
            print("Verified claim UID doesn't match!")
            return False
    except:
        # Verification failed one way or another
        print("Exception thrown during token verification.")
        return False

loop = asyncio.get_event_loop()
success = loop.run_until_complete(token_verification_task())
if (success):
    exit(0)
else:
    exit(1)

