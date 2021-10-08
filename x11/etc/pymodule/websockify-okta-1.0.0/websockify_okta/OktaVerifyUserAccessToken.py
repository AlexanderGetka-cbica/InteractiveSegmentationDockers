import os, sys, json, requests
from okta_jwt_verifier import JWTVerifier
from websockify.token_plugins import BasePlugin
import traceback
import asyncio

#introspect_url = os.environ['INTROSPECT_URL']
#client_secret = os.environ['CLIENT_SECRET']
client_id = os.environ['OKTA_CLIENT_ID']
access_token = sys.argv[1]
user_id = os.environ['OKTA_USER_ID']
issuer_url = os.environ['OKTA_ISSUER_URL']
audience = os.environ['OKTA_AUDIENCE'] 

ALLOW_ANY_VALID_USER = True

class OktaVerifyUserAccessToken(BasePlugin):
    def __init__(self, src):
        target = src.split(':')
        self.source = (target[0], target[1]) # host, port tuple

    def lookup(self, token):
        # return None if we fail, return the provided token-source otherwise. token-source is just destination host:port
        loop = asyncio.get_event_loop()
        result = loop.run_until_complete(self.token_verification_task(token))
        return result

    async def token_verification_task(self, token):
        try:
            jwt_verifier = JWTVerifier(issuer_url, client_id, audience)
            headers, claims, signing_input, signature = jwt_verifier.parse_token(token)
            #print("Claims:")
            #pprint.pprint(claims)
            # Will throw exception if verification fails
            await jwt_verifier.verify_access_token(token)
            if (ALLOW_ANY_VALID_USER or (claims['uid'] == user_id)):
                # Success
                print("Verified claim UID matches.")
                return self.source
            else:
                # Failure -- UID mismatch
                print("Verified claim UID doesn't match!")
                return None
        except:
            # Verification failed one way or another
            print("Exception thrown during token verification.")
            traceback.print_exc()
            return None


    # Not used for right now -- needs OKTA CLIENT_SECRET and INTROSPECT_URL
    def verify_remotely(self, token):
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



