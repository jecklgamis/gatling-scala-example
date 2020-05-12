#!/usr/bin/env bash
docker run -e "JAVA_OPTS=-DbaseUrl=http://some-host:8080" \
           -e SIMULATION_NAME=gatling.test.example.simulation.ExampleGetSimulation jecklgamis/gatling-test-example:latest