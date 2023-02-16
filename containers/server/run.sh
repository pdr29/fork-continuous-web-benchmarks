#!/usr/bin/env bash

[[ $# -ne 2 ]] && echo "Usage: $0 <projectid> <buncket name>" && exit 1

PROJECT_ID=$1
BUCKET=$2

echo "Starting server for Project ID: ${PROJECT_ID} Bucket: ${BUCKET}"

while [ true ]; do
  apps=$(gsutil ls gs://${BUCKET}/server/*.jar)
  if [ $? -ne 0 ]; then
    sleep 5
    continue
  fi

  for app in $apps; do
    gsutil mv $app .
    app=`basename $app`
    echo "Starting server $app"
    java -jar $app
    echo "Server $app stopped"
  done
done