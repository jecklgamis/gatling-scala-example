# gatling-scala-example

[![Build](https://github.com/jecklgamis/gatling-scala-example/actions/workflows/build.yaml/badge.svg)](https://github.com/jecklgamis/gatling-scala-example/actions/workflows/build.yaml)

This is an example test using [Gatling](https://gatling.io/). A minimal HTTP server is used as an example system under
test.
[Dockerfile](Dockerfile)
This example demonstrates a number of ways of running simulations :

* Running from an executable jar file - this packages the Gatling runtime and simulations into a single jar file
* Running using Docker - this uses the executable jar file to execute simulations inside a Docker container
* Running as Kubernetes Job - this uses the Docker image to run test inside a Kubernetes cluster
* Running using Maven plugin - this uses the Gatling Maven Plugin and runs directly from repo (note Gatling has plugins
  for Gradle and SBT that might suit your use case)

This is a **Github Template** project. You can create a copy of this project from a clean slate. Simply click
<kbd>Use this template</kbd> button.

## Requirements 
* JDK 21

## Java and Kotlin DSL

Gatling now supports Java and Kotlin DSLs. Here are some example Maven projects.

* [gatling-kotlin-example](https://github.com/jecklgamis/gatling-kotlin-example)
* [gatling-java-example](https://github.com/jecklgamis/gatling-java-example)

## Getting Started

Start the example app on port 8080. The test app is a minimal HTTP server written in NodeJS. The server simply logs the
request and returns any request body or query params it receives.

Ensure you have NodeJS installed :
```
cd example-app
node http-server.js 8080
```

## The Test App

http-server.js:
```
var http = require('http');
var port = 5050;

if (process.argv.length <= 2) {
    console.log("Requires port number");
    process.exit();
}

var host = "0.0.0.0";
var port = process.argv[2];

var server = http.createServer(function (request, response) {
    var body = [];
    var request_log = {
        type: "request",
        method: request.method,
        headers: request.headers,
        host: request.headers.host
    };
    request.on('data', function (chunk) {
        body.push(chunk);
    }).on('end', function () {
        body = Buffer.concat(body).toString();
        var message = {"ok": "true", body: body};
        request_log.body = body;
        console.log(JSON.stringify(request_log));
        response.end(JSON.stringify(message))
    });
    response.setHeader('X-Source', 'http-server.js');

});

server.listen(port, function () {
    console.log("HTTP server listening on http://%s:%d", host, port);
});
```

## The Test Simulation

```
import gatling.test.example.simulation.PerfTestConfig.{baseUrl, durationMin, maxResponseTimeMs, meanResponseTimeMs}
import io.gatling.core.Predef.{StringBody, constantUsersPerSec, global, scenario, _}
import io.gatling.http.Predef.{http, status, _}
import scala.language.postfixOps

class ExampleSimulation extends Simulation {
  val httpConf = http.baseURL(baseUrl)
  val rootEndPointUsers = scenario("Root end point calls")
    .exec(http("root end point")
      .post("/")
      .header("Content-Type", "application/json")
      .header("Accept-Encoding", "gzip")
      .body(StringBody("{}"))
      .check(status.is(200))
    )
  setUp(rootEndPointUsers.inject(
    constantUsersPerSec(PerfTestConfig.requestPerSecond) during (durationMin minutes))
    .protocols(httpConf))
    .assertions(
      global.responseTime.max.lt(meanResponseTimeMs),
      global.responseTime.mean.lt(maxResponseTimeMs),
      global.successfulRequests.percent.gt(95)
    )
}
```

The `PerfTestConfig.scala` contains the configurable values such as target url or duration. 

```
object PerfTestConfig {
  val baseUrl = getAsStringOrElse("baseUrl", "http://localhost:8080")
  val requestPerSecond = getAsDoubleOrElse("requestPerSecond", 10f)
  val durationMin = getAsIntOrElse("durationMin", 1)
  val meanResponseTimeMs = getAsIntOrElse("meanResponseTimeMs", 500)
  val maxResponseTimeMs = getAsIntOrElse("maxResponseTimeMs", 1000)
}
```

## Running Test Using Gatling Maven Plugin

The `gatling-test-maven` in `pom.xml` is configured behind a Maven profile `perf-test`. To run the tests, enable the
profile when running `mvn test` command.

```
mvn test -Pperf-test
```

The plugin is configured to run `gatling.test.example.simulation.ExampleSimulation` by default. Override the
property `simulationClass` to run a different simulation.

```
mvn test -Pperf-test -DsimulationClass=gatling.test.example.simulation.SomeOtherSimulation
```

The plugin can be configured to run all the simulations by setting the configuration property `runMultipleSimulations`
to `true`.

## Running Test Using Executable Jar

This is a self contained executable jar file containing the Gatling runtime and the simulations.

```mvn clean install
java -cp target/gatling-scala-example.jar io.gatling.app.Gatling -s gatling.test.example.simulation.ExampleSimulation
```

## Running Test Using Docker Container

Create a Docker container:

```
mvn clean package 
docker build -t gatling-scala-example .
```

You alternatively run `make dist image`.

Run the Docker container:

```
docker run -e "JAVA_OPTS=-DbaseUrl=http://localhost:8080" \
     -e SIMULATION_NAME=gatling.test.example.simulation.ExampleGetSimulation gatling-scala-example:latest
```

This runs `ExampleGetSimulation` test against an HTTP server `localhost` running on port 8080.

## Running Test as Kubernetes Job

This assumes you have a basic knowledge of [Kubernetes](https://kubernetes.io/docs/tutorials/kubernetes-basics/),
access to a Kubernetes cluster, a properly configured `kubectl` (`~/.kube/config`), and [Helm](https://helm.sh) installed.

The simulation is deployed as a Kubernetes Job using the Helm chart in `deployment/k8s/helm/chart`.

### Quick Start

```bash
./run-simulation-using-kubernetes.sh
```

### Configuration

The script is configured via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `SIMULATION_NAME` | `ExampleGetSimulation` | Fully qualified simulation class name |
| `BASE_URL` | `http://localhost:8080` | Target URL |
| `DURATION_MIN` | `0.25` | Test duration in minutes |
| `REQUEST_PER_SECOND` | `10` | Load rate |
| `P95_RESPONSE_TIME_MS` | `250` | 95th percentile threshold (ms) |
| `IMAGE_REPOSITORY` | `jecklgamis/gatling-scala-example` | Docker image repository |
| `IMAGE_TAG` | `main` | Docker image tag |
| `NAMESPACE` | `default` | Kubernetes namespace |
| `TIMEOUT` | `300s` | Job completion timeout |

Example:

```bash
BASE_URL=http://my-service:8080 \
  SIMULATION_NAME=gatling.test.example.simulation.ExamplePostSimulation \
  REQUEST_PER_SECOND=50 \
  ./run-simulation-using-kubernetes.sh
```

The script installs a Helm release with a unique timestamped name, waits for the job to complete or fail,
prints simulation logs, and uninstalls the release automatically.


## Example Target Apps

Some example apps.

Dropwizard Apps:

* https://github.com/jecklgamis/dropwizard-java-example
* https://github.com/jecklgamis/dropwizard-kotlin-example
* https://github.com/jecklgamis/dropwizard-scala-example

Spring Boot Apps:

* https://github.com/jecklgamis/spring-boot-java-example
* https://github.com/jecklgamis/spring-boot-kotlin-example
* https://github.com/jecklgamis/spring-boot-scala-example

Flask App:

* https://github.com/jecklgamis/flask-app-example
* https://github.com/jecklgamis/fastapi-app-example

## Links

* Gatling: http://gatling.io
* Scala: http://scala-lang.org






