#!/usr/bin/env bash
set -euo pipefail

GATLING_SERVER_URL=${GATLING_SERVER_URL:-http://localhost:58080}
JAR_FILE=${JAR_FILE:-target/gatling-scala-example.jar}
API_TOKEN=${API_TOKEN:-default}

if [[ ! -f "${JAR_FILE}" ]]; then
  echo "Jar file not found: ${JAR_FILE}. Run './mvnw clean package' first." >&2
  exit 1
fi

curl -v \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -F "file=@${JAR_FILE}" \
  "${GATLING_SERVER_URL}/upload"
