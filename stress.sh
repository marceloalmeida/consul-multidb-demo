#!/bin/bash

# Simple test without locking concurrency

#CONSUL_URL="http://172.20.21.11:8500"
CONSUL_URL="http://172.20.21.1$(($RANDOM % 3 +1)):8500"
SERVICE="dbservice"
PAYLOAD_SIZE=2048
PAYLOAD="{\"key\": \"$(head -c $PAYLOAD_SIZE </dev/urandom | base64)\"}"

SESSION_ID=$(curl -s -X PUT -d '{"Name": "'$SERVICE'", "TTL": "10s"}' $CONSUL_URL/v1/session/create | jq -r .ID)


curl -s -X PUT -d "$PAYLOAD" $CONSUL_URL/v1/kv/$SERVICE/$SESSION_ID?acquire=$SESSION_ID | jq .
#curl -s -X PUT -d "$PAYLOAD" $CONSUL_URL/v1/kv/$SERVICE/$SESSION_ID?acquire=$SESSION_ID -o /dev/null


curl -s -X GET $CONSUL_URL/v1/kv/$SERVICE/$SESSION_ID?acquire=$SESSION_ID | jq .
#curl -s -X GET $CONSUL_URL/v1/kv/$SERVICE/$SESSION_ID?acquire=$SESSION_ID -o /dev/null

if [[ "$(($RANDOM % 5))" -eq "0" ]]; then
  curl -s -X DELETE $CONSUL_URL/v1/kv/$SERVICE/$SESSION_ID?acquire=$SESSION_ID | jq .
  #curl -s -X DELETE $CONSUL_URL/v1/kv/$SERVICE/$SESSION_ID?acquire=$SESSION_ID -o /dev/null
fi
