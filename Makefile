IMAGE_NAME:=jecklgamis/gatling-test-example
IMAGE_TAG:=latest
default:
	cat ./Makefile
dist: 
	mvn clean package
image:
	 docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
run-bash:
	 docker run -i -t $(IMAGE_NAME):$(IMAGE_TAG) /bin/bash
run:
	 docker run -e "JAVA_OPTS=-DbaseUrl=http://some-app:8080" -e SIMULATION_NAME=gatling.test.example.simulation.ExampleGetSimulation gatling-test-example:latest
push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

