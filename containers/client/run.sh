#!/usr/bin/env bash

# For each jar found from gs://${BUCKET}/client/*.jar ->
# - copy the jar into gs://${BUCKET}/server/
# - wait for the server to be started (listen on 8080)
# - run Gatling sumulations
# - copy results into gs://${BUCKET}/results/
# - send a special http request to the server, asking him to exit

set -v

SERVER_HOST=$1
SIMULATIONS=$2
INCREMENT=$3
STEPS=$4

echo "Running simulations: ${SIMULATIONS} for all jars from bucket client directory"

while [ true ]; do
  apps=$(gsutil ls gs://${BUCKET}/client/*.jar)
  if [ $? -ne 0 ]; then
    echo "No application to run from gs://${BUCKET}/client/, stopping."
    exit 0
  fi


  echo "[" > /opt/bench/gh-benchmark.json
  
  for app in $apps; do
    echo "Found application $app, moving it to server bucket"
    gsutil mv $app gs://${BUCKET}/server/
    app=$(basename $app .jar)
    # Server is expected to have started the app, wait for the 8080 port to be available
    curl http://$SERVER_HOST/text \
      --silent \
      --fail \
      --location \
      --retry 30 \
      --retry-connrefused \
      --retry-delay 6 \
      --retry-max-time 300

    # Now, start gatling for this particular app
    for simulation in $(echo ${SIMULATIONS} | tr ";" "\n"); do
      export JAVA_OPTS="-DbaseUrl=http://${SERVER_HOST} -Dincrement=${INCREMENT} -Dsteps=${STEPS}"
      mean=$(/opt/bench/gatling/bin/gatling.sh --run-description "Benchmark for application ${app}" -s ${simulation} -bm --run-mode local | grep "mean requests/sec"|awk  '{print $4}')
cat <<EOF >> /opt/bench/gh-benchmark.json
{
	"name": "$app-$simulation",
	"unit": "mean requests/sec",
	"value": "$mean"
}
,
EOF
      rm /opt/bench/gatling/results/**/simulation.log
    done

    if [[ $BUCKET ]]; then
      cd /opt/bench/gatling/
      mv results ${app}
      tar -czf "/opt/bench/${app}.tar.gz" ${app}
      cd -
    fi

    # ask the server to exit
    curl -v http://$SERVER_HOST/exit
  done


  # remove last line from /opt/bench/gh-benchmark.json
  sed -i '$d' /opt/bench/gh-benchmark.json

  # close the json file
  echo "]" >> /opt/bench/gh-benchmark.json
  
  # all done, copy results into buncket
  gsutil cp "/opt/bench/*.tar.gz" "gs://${BUCKET}/results/"
  gsutil cp /opt/bench/gh-benchmark.json "gs://${BUCKET}/results/"
done

