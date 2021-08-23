#!/bin/bash
SIMULATION_NAME=${SIMULATION_NAME:-gatling.test.example.simulation.ExampleGetSimulation}
exec java ${JAVA_OPTS} -cp bin/gatling-test-example.jar  io.gatling.app.Gatling -s ${SIMULATION_NAME}
