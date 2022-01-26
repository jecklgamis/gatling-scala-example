package gatling.test.example.simulation

import gatling.test.example.simulation.PerfTestConfig.{baseUrl, durationMin, maxResponseTimeMs, meanResponseTimeMs, p95ResponseTimeMs}
import io.gatling.core.Predef.{constantUsersPerSec, global, scenario, _}
import io.gatling.http.Predef.{http, status, _}

import scala.concurrent.duration._
import scala.language.postfixOps

class ExampleGetSimulation extends Simulation {
  val httpConf = http.baseUrl(baseUrl)
  val getUsers = scenario("Root end point calls")
    .exec(http("root end point")
      .get("/")
      .check(status.is(200))
    )
  setUp(getUsers.inject(
    constantUsersPerSec(PerfTestConfig.requestPerSecond) during (durationMin minutes))
    .protocols(httpConf))
    .assertions(
      global.responseTime.max.lt(maxResponseTimeMs),
      global.responseTime.mean.lt(meanResponseTimeMs),
      global.responseTime.percentile3.lt(p95ResponseTimeMs),
      global.successfulRequests.percent.gt(95)
    )
}


