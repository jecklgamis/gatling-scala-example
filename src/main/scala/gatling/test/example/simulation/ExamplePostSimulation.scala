package gatling.test.example.simulation

import gatling.test.example.simulation.PerfTestConfig._
import io.gatling.core.Predef.{constantUsersPerSec, global, scenario, _}
import io.gatling.http.Predef.{http, status, _}

import java.util.UUID
import scala.concurrent.duration._
import scala.language.postfixOps

class ExamplePostSimulation extends Simulation {
  val uuidFeeder = Iterator.continually(Map("someUuid" -> s"${UUID.randomUUID().toString.substring(0, 8)}"))
  val httpConf = http.baseUrl(baseUrl)
  val postUsers = scenario("Root end point calls")
    .feed(uuidFeeder)
    .exec(http("root end point")
      .post("/")
      .header("Content-Type", "application/json")
      .header("Accept-Encoding", "gzip")
      .body(ElFileBody("example-request.json"))
      .check(status.is(200))
    )
  setUp(postUsers.inject(
    constantUsersPerSec(requestPerSecond) during (durationMin minutes))
    .protocols(httpConf))
    .assertions(
      global.responseTime.max.lt(maxResponseTimeMs),
      global.responseTime.mean.lt(meanResponseTimeMs),
      global.responseTime.percentile3.lt(p95ResponseTimeMs),
      global.successfulRequests.percent.gt(95)
    )
}


