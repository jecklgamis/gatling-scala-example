#!/usr/bin/env bash
JAVA_OPTS="-DbaseUrl=http://localhost:8080  -DdurationMin=0.25 -DrequestPerSecond=10"
SIMULATION_NAME=gatling.test.example.simulation.ExampleSimulation
java ${JAVA_OPTS} -cp target/gatling-test-example.jar io.gatling.app.Gatling -s "${SIMULATION_NAME}"
