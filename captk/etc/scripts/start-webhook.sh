#!/bin/bash

# This block is only for if webhook itself is handling SSL
if [ -n "$SSL_CERT" ] && [ -n "$SSL_KEY" ]; then
  webhook -hooks /etc/webhook/hooks.json -port 7000 -secure -key "$SSL_KEY" -cert "$SSL_CERT" -verbose
else
  webhook -hooks /etc/webhook/hooks.json -port 7000 -verbose
fi

#  HTTP only
#webhook -hooks /etc/webhook/hooks.json -port 7000 -verbose &

