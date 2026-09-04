#!/usr/bin/env bash
set -euo pipefail

GATLING_SERVER_URL=${GATLING_SERVER_URL:-http://localhost:58080}
JAR_FILE=${JAR_FILE:-target/gatling-scala-example.jar}
SIMULATION_NAME=${SIMULATION_NAME:-gatling.test.example.simulation.ExampleSimulation}
JAVA_OPTS=${JAVA_OPTS:-"-DbaseUrl=http://localhost:8080 -DdurationMin=0.25 -DrequestPerSecond=10"}
API_TOKEN=${API_TOKEN:-default}

if [[ ! -f "${JAR_FILE}" ]]; then
  echo "Jar file not found: ${JAR_FILE}. Run './mvnw clean package' first." >&2
  exit 1
fi

curl -v \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -F "file=@${JAR_FILE}" \
  -F "simulation=${SIMULATION_NAME}" \
  -F "javaOpts=${JAVA_OPTS}" \
  "${GATLING_SERVER_URL}/task/upload/http"
