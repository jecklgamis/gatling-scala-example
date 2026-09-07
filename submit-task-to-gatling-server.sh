#!/usr/bin/env bash
set -euo pipefail

GATLING_SERVER_URL=${GATLING_SERVER_URL:-http://localhost:58080}
API_TOKEN=${API_TOKEN:-default}
REQUEST_FILE=${REQUEST_FILE:-gatling-server-task.json}

if [[ ! -f "${REQUEST_FILE}" ]]; then
  echo "Request file not found: ${REQUEST_FILE}" >&2
  exit 1
fi

curl -v \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @"${REQUEST_FILE}" \
  "${GATLING_SERVER_URL}/task/submit"
