#!/usr/bin/env bash
java ${JAVA_OPTS} -cp target/gatling-test-example.jar io.gatling.app.Gatling -s gatling.test.example.simulation.ExampleSimulation
