IMAGE_NAME:=gatling-scala-example
IMAGE_TAG:=$(shell git rev-parse --abbrev-ref HEAD)

default:
	@cat ./Makefile
dist:
	./mvnw clean package
image:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
run-bash:
	docker run -i -t $(IMAGE_NAME):$(IMAGE_TAG) /bin/bash
run:
	docker run -e "JAVA_OPTS=-DbaseUrl=http://localhost:8080 -DdurationMin=0.25 -DrequestPerSecond=10" \
  	-e SIMULATION_NAME=gatling.test.example.simulation.ExampleGetSimulation $(IMAGE_NAME):$(IMAGE_TAG)
all: dist image
clean:
	./mvnw clean