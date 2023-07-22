#!/usr/bin/env bash
curl -v \
  -F 'file=@./target/gatling-scala-example-lean.jar' \
  -F "simulation=gatling.test.example.simulation.ExampleSimulation" \
  -F "javaOpts=-DbaseUrl=http://localhost:8080 -DdurationMin=0.25 -DrequestPersecond=1" \
  http://localhost:58080/task/upload/http
