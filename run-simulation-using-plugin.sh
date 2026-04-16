#!/usr/bin/env bash
mvn gatling:test -DbaseUrl=http://localhost:8080 -DdurationMin=1 -DrequestPerSecond=10 -Dgatling.simulationClass=gatling.test.example.simulation.ExampleSimulation
