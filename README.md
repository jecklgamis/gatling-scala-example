# gatling-test-example 

[![CircleCI](https://circleci.com/gh/jecklgamis/gatling-test-example.svg?style=svg)](https://circleci.com/gh/jecklgamis/gatling-test-example)

This is an example test using Gatling. A minimal HTTP server is used as an example system under test.

This example demonstrates a number of ways of running Gatling simulations:
* Running from an executable jar file - this packages the Gatling runtime and simulations into a single jar file
* Running using Docker - this uses the executable jar file to execute simulations inside a Docker container
* Running as Kubernetes Job  - this uses the Docker image to run test inside a Kubernetes cluster
* Running using Maven plugin - this is uses the Gatling Maven Plugin and runs directly from repo (note Gatling has 
plugins for Gradle and SBT that might suit your use case)
* Running inside IDE  - this uses a helper class `Engine.scala` to run simulations from IDE. Useful for crafting your
simulations or  if your just getting started
* See [gatling-server](https://github.com/jecklgamis/gatling-server) for running simulations using an API server.

## Getting Started

Start the example app on port 8080. The test app is a minimal HTTP server written in NodeJS. The
server simply logs the request and  returns any request body it receives.

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

From the IDE, run `Engine.scala` and just accept the default run description. The test will send HTTP requests to 
`http://localhost:8080/` for 1 minute at 10 requests per second. The test also asserts mean response time
time to be less than 500ms, max response less than  1000ms, and success rate of 95%. 

Below is the actual test simulation.

```
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

The url, rate, duration, and asserted values are in `PerfTestConfig.scala`.

TIP: The `Engine.scala` and `IDEPathHelper.scala` classes are generated from the Gatling Maven Archetype
(http://gatling.io/docs/current/extensions/maven_archetype/).


```
object PerfTestConfig {
  val baseUrl = getAsStringOrElse("baseUrl", "http://localhost:8080")
  val requestPerSecond = getAsDoubleOrElse("requestPerSecond", 10f)
  val durationMin = getAsIntOrElse("durationMin", 1)
  val meanResponseTimeMs = getAsIntOrElse("meanResponseTimeMs", 500)
  val maxResponseTimeMs = getAsIntOrElse("maxResponseTimeMs", 1000)
}
```

## The Test Results

This is an example test run result from the IDE.

```
Simulation gatling.test.example.simulation.ExampleSimulation completed in 59 seconds
Parsing log file(s)...
Parsing log file(s) done
Generating reports...

================================================================================
---- Global Information --------------------------------------------------------
> request count                                        600 (OK=600    KO=0     )
> min response time                                      1 (OK=1      KO=-     )
> max response time                                     10 (OK=10     KO=-     )
> mean response time                                     2 (OK=2      KO=-     )
> std deviation                                          1 (OK=1      KO=-     )
> response time 50th percentile                          2 (OK=2      KO=-     )
> response time 75th percentile                          2 (OK=2      KO=-     )
> response time 95th percentile                          4 (OK=4      KO=-     )
> response time 99th percentile                          5 (OK=5      KO=-     )
> mean requests/sec                                     10 (OK=10     KO=-     )
---- Response Time Distribution ------------------------------------------------
> t < 800 ms                                           600 (100%)
> 800 ms < t < 1200 ms                                   0 (  0%)
> t > 1200 ms                                            0 (  0%)
> failed                                                 0 (  0%)
================================================================================

Reports generated in 0s.
Please open the following <some-dir>/target/results/examplesimulation-1503897964328/index.html
Global: max of response time is less than 500.0 : true
Global: mean of response time is less than 1000.0 : true
Global: percentage of successful requests is greater than 95.0 : true
```

A more detailed test result in HTML can be found in `target/results`.

## Running Test Using Gatling Maven Plugin

The `gatling-test-maven` in `pom.xml` is configured behind a Maven profile `perf-test`. To run the tests, simply 
enable the profile when running `mvn test` command.

```
mvn test -Pperf-test.
```

The plugin is configured to run `gatling.test.example.simulation.ExampleSimulation` by default.
Simply override the property `simulationClass` to run a different simulation.

```
mvn test -Pperf-test -DsimulationClass=gatling.test.example.simulation.SomeOtherSimulation
```

The plugin can be configured to run all the simulations by setting the configuration property `runMultipleSimulations` 
to `true`.

## Running Test Using Executable Jar
```
mvn clean install
java ${JAVA_OPTS} -cp target/gatling-test-example.jar io.gatling.app.Gatling -s gatling.test.example.simulation.ExampleSimulation
```

## Running Test Using Docker Container

Create a Docker container (`make dist image`):
```
mvn clean package 
docker build -t gatling-test-example .
```

Run the Docker container (`make run`):
```
docker run -e "JAVA_OPTS=-DbaseUrl=http://some-target-host:8080" -e SIMULATION_NAME=gatling.test.example.simulation.ExampleGetSimulation gatling-test-example:latest
```
This runs `ExampleGetSimulation` test against an HTTP server `some-target-host` running on port 8080.

## Running Test as Kubernetes Job

This assumes you have a basic knowledge of [Kubernetes](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
and a have access to a Kubernetes cluster. This usually means you have a properly configured `kubectl` config
(`~/.kube/config`). Also ensure you have Python 3 installed. 

In this example setup, a  [Jinja2](https://palletsprojects.com/p/jinja/)  template `job-template.yaml` is used generate the 
actual Job yaml file to be used in `kubectl`. The helper script `./create-job-yaml.py` is used to generate this file.

#### Install Python 3 dependencies
```
pip3 install jinja2 argparse
```

Here is a demo run using the helper scripts in `deployment/k8s/job`. 

![Kubernetes Job Demo](k8s-job-demo.gif)

You should be able to replicate it in your local environment.
```shell script
cd deployment/k8s/job
./demo-run-in-k8s.sh
```

For a step by step procedure, read on.

1.  Generate `job.yaml` from `job-template.yaml`
```
cd deployment/k8s/job
./create-job-yaml.py --out job.yaml --name gatling-test-example --java_opts "-DbaseUrl=http://some-target-host:8080 -DdurationMin=0.25 -DrequestPerSecond=10" --simulation "gatling.test.example.simulation.ExampleGetSimulation"
```

`job-template.yaml` template file.
```
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ name }}"
spec:
  backoffLimit: 0
  template:
    spec:
      containers:
        - name: gatling-test-example
          image: jecklgamis/gatling-test-example
          imagePullPolicy: Always
          env:
            - name: JAVA_OPTS
              value: "{{ java_opts }}"
            - name: SIMULATION_NAME
              value: "{{ simulation_name }}"
      restartPolicy: Never
```

2. Create Job 
```shell script
kubectl apply -f job.yaml
```
Example output:
```shell script
job.batch/gatling-test-example created
```

3. View Job 
```shell script
kubectl get jobs/gatling-test-example -o wide
```
Example output:
```shell script
NAME                   COMPLETIONS   DURATION   AGE   CONTAINERS             IMAGES                            SELECTOR
gatling-test-example   1/1           24s        25s   gatling-test-example   jecklgamis/gatling-test-example   controller-uid=2f37ee78-09b9-4aa9-90ac-872db13522b6
```

4. View Pods
```shell script
kubectl get pods -l job-name=gatling-test-example -o wide
```
Example output:
```shell script
NAME                         READY   STATUS      RESTARTS   AGE   IP             NODE      NOMINATED NODE   READINESS GATES
gatling-test-example-2mz4s   0/1     Completed   0          56s   10.244.0.237   okinawa   <none>           <none>
```

5. Get Pod Logs
```shell script
kubectl logs <pod-name>
```

6. Delete Job
```shell script
kubectl delete -f job.yaml
```

### Reference Helper Scripts

The scripts below can be found in `deployment/k8s/job` directory.

* [create-job.sh](deployment/k8s/job/create-job.sh) 
* [describe-job.sh](deployment/k8s/job/describe-job.sh) 
* [describe-pod.sh](deployment/k8s/job/describe-pod.sh)
* [wait-job.sh](deployment/k8s/job/wait-job.sh) 
* [delete-job.sh](deployment/k8s/job/delete-job.sh) 

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
* https://github.com/jecklgamis/flask-example-app
  
## Links
* Gatling: http://gatling.io  
* Scala: http://scala-lang.org






