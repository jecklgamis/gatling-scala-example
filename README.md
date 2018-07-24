# gatling-test-example [![Build Status](https://travis-ci.org/jecklgamis/gatling-test-example.svg?branch=master)](https://travis-ci.org/jecklgamis/gatling-test-example)

This is an example test using Gatling. A minimal HTTP server is used as an example system under test.
Gatling simulations are written in Scala.

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
  
## Links
* Gatling: http://gatling.io  
* Scala: http://scala-lang.org






