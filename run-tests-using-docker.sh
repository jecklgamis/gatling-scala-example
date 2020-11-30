#!/usr/bin/env bash
docker run -e "JAVA_OPTS=-DbaseUrl=http://localhost:8080  -DdurationMin=0.25 -DrequestPerSecond=10" \
  -e SIMULATION_NAME=gatling.test.example.simulation.ExampleGetSimulation jecklgamis/gatling-test-example:latest
