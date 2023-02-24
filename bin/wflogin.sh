#!/usr/bin/env bash

set -euo pipefail

# Logs into wf CLI using the specified profile name and the JSON file from
# a `wf install --in-cluster --json-file ./env.json`

PROFILE=$1
JSON_FILE=$2

echo -n " using profile ${PROFILE} and JSON_FILE ${JSON_FILE} \n"

WF_API_URL="$(cat ${JSON_FILE} | jq -r '.login.url')"
WF_ADMIN_USER="$(cat ${JSON_FILE} | jq -r '.login.username')"
WF_ADMIN_PASS="$(cat ${JSON_FILE} | jq -r '.login.password')"

echo -n "Attempting to log in to ${WF_API_URL} as ${WF_ADMIN_USER}..."
SUCCESS="false"
TIME_USED=0
TIMEOUT=180
while [[ "${SUCCESS}" == "false" && $TIME_USED -lt ${TIMEOUT} ]]; do
  set +euo pipefail
  wf login ${PROFILE} -a ${WF_API_URL} --force -u ${WF_ADMIN_USER} -p ${WF_ADMIN_PASS} --non-interactive >/dev/null 2>&1
  if [ $? = 0 ]; then
    SUCCESS="true"
  fi
  set -euo pipefail
  let TIME_USED=TIME_USED+2
  if [[ "${SUCCESS}" == "false" && $TIME_USED -lt ${TIMEOUT} ]]; then
    echo -n "."
    sleep 2
  fi
done
echo ""
if [[ "${SUCCESS}" == "false" ]]; then
  echo "Login not successful after ${TIMEOUT}s, cannot continue"
  exit 1
fi
echo "Logged in as ${WF_ADMIN_USER}"
