#!/bin/bash

cp -r /etc/pymodule/websockify-okta-1.0.0/websockify_okta ./

if [ -n "$SSL_CERT" ] && [ -n "$SSL_KEY" ]; then
  websockify 127.0.0.1:9900 --token-plugin websockify_okta.OktaVerifyUserAccessToken --token-source 127.0.0.1:5900 --cert "$SSL_CERT" --key "$SSL_KEY"
else
  websockify 127.0.0.1:9900 --token-plugin websockify_okta.OktaVerifyUserAccessToken --token-source 127.0.0.1:5900
fi

# SSL is already terminated at the nginx level
#websockify 127.0.0.1:9900 --token-plugin websockify_okta.OktaVerifyUserAccessToken --token-source 127.0.0.1:5900

