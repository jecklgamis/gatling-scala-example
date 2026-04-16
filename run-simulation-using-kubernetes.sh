#!/usr/bin/env bash
set -euo pipefail

CHART_DIR="$(cd "$(dirname "$0")/deployment/k8s/helm/chart" && pwd)"
RELEASE_NAME="gatling-scala-example-run-$(date +%s)"

SIMULATION_NAME=${SIMULATION_NAME:-gatling.test.example.simulation.ExampleGetSimulation}
BASE_URL=${BASE_URL:-http://localhost:8080}
DURATION_MIN=${DURATION_MIN:-0.25}
REQUEST_PER_SECOND=${REQUEST_PER_SECOND:-10}
P95_RESPONSE_TIME_MS=${P95_RESPONSE_TIME_MS:-250}
IMAGE_REPOSITORY=${IMAGE_REPOSITORY:-jecklgamis/gatling-scala-example}
IMAGE_TAG=${IMAGE_TAG:-main}
NAMESPACE=${NAMESPACE:-default}
TIMEOUT=${TIMEOUT:-300s}
JAVA_OPTS="-DbaseUrl=${BASE_URL} -DdurationMin=${DURATION_MIN} -DrequestPerSecond=${REQUEST_PER_SECOND} -Dp95ResponseTimeMs=${P95_RESPONSE_TIME_MS}"

echo "RELEASE_NAME        : ${RELEASE_NAME}"
echo "NAMESPACE           : ${NAMESPACE}"
echo "IMAGE_REPOSITORY    : ${IMAGE_REPOSITORY}"
echo "IMAGE_TAG           : ${IMAGE_TAG}"
echo "SIMULATION_NAME     : ${SIMULATION_NAME}"
echo "JAVA_OPTS           : ${JAVA_OPTS}"
echo "TIMEOUT             : ${TIMEOUT}"
echo ""
echo "Installing Helm release: ${RELEASE_NAME}"
helm install "${RELEASE_NAME}" "${CHART_DIR}" \
  --namespace "${NAMESPACE}" \
  --set "image.repository=${IMAGE_REPOSITORY}" \
  --set "image.tag=${IMAGE_TAG}" \
  --set "image.pullPolicy=IfNotPresent" \
  --set "imagePullSecrets=" \
  --set "simulation.name=${SIMULATION_NAME}" \
  --set "simulation.javaOpts=${JAVA_OPTS}"

echo "Waiting for job ${RELEASE_NAME} to be created..."
until kubectl get jobs --namespace "${NAMESPACE}" \
  -l "app.kubernetes.io/instance=${RELEASE_NAME}" \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null | grep -q .; do
  sleep 2
done
JOB_NAME=$(kubectl get jobs --namespace "${NAMESPACE}" \
  -l "app.kubernetes.io/instance=${RELEASE_NAME}" \
  -o jsonpath='{.items[0].metadata.name}')

echo "Waiting for job ${JOB_NAME} (timeout: ${TIMEOUT})"
DEADLINE=$((SECONDS + ${TIMEOUT%s}))
until kubectl get job/"${JOB_NAME}" --namespace "${NAMESPACE}" \
  -o jsonpath='{.status.conditions[*].type}' 2>/dev/null | grep -qE 'Complete|Failed'; do
  if [[ ${SECONDS} -ge ${DEADLINE} ]]; then
    echo "Timed out waiting for job ${JOB_NAME}"
    helm uninstall "${RELEASE_NAME}" --namespace "${NAMESPACE}" || true
    exit 1
  fi
  sleep 2
done

POD=$(kubectl get pods --namespace "${NAMESPACE}" \
  -l "job-name=${JOB_NAME}" \
  -o jsonpath='{.items[0].metadata.name}')
echo "Simulation logs (pod: ${POD}):"
kubectl logs --namespace "${NAMESPACE}" "${POD}"

JOB_STATUS=$(kubectl get job/"${JOB_NAME}" --namespace "${NAMESPACE}" \
  -o jsonpath='{.status.conditions[*].type}')

echo "Uninstalling Helm release: ${RELEASE_NAME}"
helm uninstall "${RELEASE_NAME}" --namespace "${NAMESPACE}"

if echo "${JOB_STATUS}" | grep -q "Failed"; then
  echo "Simulation failed!"
  exit 1
fi
echo "Simulation completed successfully!"
