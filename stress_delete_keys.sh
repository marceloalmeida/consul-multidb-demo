#!/bin/bash

#CONSUL_URL="http://172.20.21.11:8500"
CONSUL_URL="http://172.20.21.1$(($RANDOM % 3 +1)):8500"
SERVICE="dbservice"

curl -s -X GET $CONSUL_URL/v1/kv/$SERVICE/\?recurse=true -v | jq -r '.[].Key' | while read KEY; do
  #curl -s -X DELETE $CONSUL_URL/v1/kv/$KEY | jq .
  curl -s -X DELETE $CONSUL_URL/v1/kv/$KEY -o /dev/null
done
