#!/bin/bash

#CONSUL_URL="http://172.20.21.11:8500"
CONSUL_URL="http://172.20.21.1$(($RANDOM % 3 +1)):8500"
SERVICE="dbservice"

curl -s -X GET $CONSUL_URL/v1/session/list | jq -r '.[].ID' | while read SESSION_ID; do
  #echo $SESSION_ID
  curl -s -X PUT $CONSUL_URL/v1/session/destroy/$SESSION_ID -o /dev/null
done
