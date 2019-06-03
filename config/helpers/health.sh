#!/bin/bash -e
HEALTH_CHECK_TIMEOUT=30;
HEALTH_CHECK_INTERVAL=1;
container=app

function ISODate() {
    echo $(date +%FT%TZ)
}

echo "$(ISODate): Waiting for app to start"

started=

while [[ -z $started && $HEALTH_CHECK_TIMEOUT -gt 0 ]]; do
      echo "$(ISODate): Checking $container health..."
      started=$(docker logs $container | awk "/App listening on port/")
      let HEALTH_CHECK_TIMEOUT=$HEALTH_CHECK_TIMEOUT-1
      sleep $HEALTH_CHECK_INTERVAL
done

if [[ -z $started ]];then
      echo "$(ISODate): Couldn't start the application on time"
      exit 1
fi

echo "$(ISODate): $container is healthy"
exit 0