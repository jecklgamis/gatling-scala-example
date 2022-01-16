#!/usr/bin/env bash
curl -v \
  -F 'file=@src/main/scala/gatling/test/example/simulation/SingleFileExampleSimulation.scala' \
  -F "simulation=gatling.test.example.simulation.SingleFileExampleSimulation" \
  -F "javaOpts=-DbaseUrl=http://localhost:8080 -DdurationMin=0.25 -DrequestPersecond=1" \
  http://localhost:58080/task/upload/http
