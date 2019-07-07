default:
	cat ./Makefile
dist: 
	mvn clean package
image:
	 docker build -t gatling-test-example .
run-bash:
	 docker run -i -t gatling-test-example /bin/bash
run:
	 docker run -e "JAVA_OPTS=-DbaseUrl=http://some-app:8080" -e SIMULATION_NAME=gatling.test.example.simulation.ExampleGetSimulation gatling-test-example:latest
