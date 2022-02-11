#!/bin/python3

import os, sys, requests, base64, json
from datetime import datetime
from requests.exceptions import HTTPError

client_id = os.environ['OKTA_CLIENT_ID']
#client_secret = os.environ['OKTA_CLIENT_SECRET']
#okta_captk_scope = os.environ['OKTA_SCOPE']

dart_annotationcreated_endpoint = os.environ['DART_ANNOTATIONCREATED_ENDPOINT']
#okta_token_endpoint= os.environ['OKTA_TOKEN_ENDPOINT']

if len(sys.argv) < 10:
    exit(1)

# All of the paths obtained here should be relative to the output root dir (whatever is mounted in)

study_instance_uid = sys.argv[1]
transaction_id = sys.argv[2]
roi_nifti_path = sys.argv[3]
input_niftifolder_path = sys.argv[4]
radiomics_csv_path = sys.argv[5]
metadata_file_path = sys.argv[6]
number_of_annotations = int(sys.argv[7])
user_id = sys.argv[8]
user_access_token = sys.argv[9]

new_user_access_token = user_access_token

# Use old access token (from request) and refresh token (from disk) to generate new access token
#new_user_access_token = ""
#current_refresh_token = ""
#with open("/home/researcher/refresh", "r") as f:
#    current_refresh_token = f.read().strip('\n')

#payload='grant_type=refresh_token&refresh_token='+current_refresh_token+'&scope=openid%20offline_access&client_id='+client_id+'&client_secret='+client_secret
#headers = {
#  'Content-Type': 'application/x-www-form-urlencoded',
#  'Cache-Control': 'no-cache'
#}

#response = requests.post(okta_token_endpoint, headers=headers, params=payload)

# Logging
#response_dict = json.loads(response.text)
#with open("/home/researcher/notify-dart-annotation-created.log", "a") as f:
#    f.write("URL: " + response.url + "\n")
#    f.write("RESPONSE: " + response.text + "\n")
#    #for i in response_dict:
#    #    f.write("key: ", i, " val: ", response_dict[i])

# Fail if we couldn't get a response to this first request
#if not response.ok:
#    exit(1)

# Now extract new refresh and access tokens
#new_refresh_token = response_dict["refresh_token"]
#new_user_access_token = response_dict["access_token"]

# Write out refresh token
#with open("/home/researcher/refresh", "w") as f:
#    f.write(new_refresh_token)


# Get token from client-credentials flow
#authorization = base64.b64encode(bytes(client_id + ":" + client_secret, "ISO-8959-1")).decode("ascii")

#headers = {
#    "Authorization": f"Basic {authorization}",
#    "Content-Type": "application/x-www-form-urlencoded",
#    "Cache-Control": "no-cache",
#    "Accept": "application/json"
#}
#body = {
#    "grant_type": "client_credentials",
#    "scope": okta_captk_scope
#}

#granted_token = None
#try:
#    response = requests.post(okta_token_endpoint, data=body, headers=headers)
#    response.raise_for_status()
#    # access JSON content
#    jsonResponse = response.json()
#    print("Entire JSON response")
#    print(jsonResponse)
#except HTTPError as http_err:
#    print(f'HTTP error occurred: {http_err}')
#except Exception as err:
#    print(f'Other error occurred: {err}')

# Use refresh token to get get a new valid access token


#granted_token = jsonResponse['access_token']
# Information to go in the actual request to DART goes here

# Use the new token granted to make our request
headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer " + new_user_access_token
}
body = {}
body['studyInstanceUid'] = study_instance_uid
body['transactionId'] = transaction_id
body['roiNiftiPath'] = roi_nifti_path
body['inputNiftiFolderPath'] = input_niftifolder_path
body['radiomicsCSVPath'] = radiomics_csv_path
body['metadataFilePath'] = metadata_file_path
body['numberOfAnnotations'] = number_of_annotations
body['userId'] = user_id
#body['token'] = user_access_token
response = requests.post(dart_annotationcreated_endpoint, data=json.dumps(body), headers=headers)
with open('/home/researcher/notify-dart-annotation-created.log', "a") as f:
    f.write("JSON data:" + json.dumps(body)+ "\n")
now = datetime.now()
dt_string = now.strftime("%d/%m/%y %H:%M:%S ")
with open('/home/researcher/notify-dart-annotation-created.log', "a") as f:
    f.write(dt_string + response.text + " " + str(response.status_code) + " " + response.reason + "\n")

if response.ok:
    exit(0)
else:
    exit(1)


