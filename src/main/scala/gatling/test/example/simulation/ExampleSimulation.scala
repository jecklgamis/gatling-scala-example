package gatling.test.example.simulation

import gatling.test.example.simulation.PerfTestConfig._
import io.gatling.core.Predef.{StringBody, constantUsersPerSec, global, scenario, _}
import io.gatling.http.Predef.{http, status, _}

import scala.concurrent.duration._
import scala.language.postfixOps

class ExampleSimulation extends Simulation {

  val httpConf = http.baseUrl(baseUrl)
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
      global.responseTime.max.lt(maxResponseTimeMs),
      global.responseTime.mean.lt(meanResponseTimeMs),
      global.responseTime.percentile3.lt(p95ResponseTimeMs),
      global.successfulRequests.percent.gt(95)
    )
}


