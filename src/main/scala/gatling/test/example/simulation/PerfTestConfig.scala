package gatling.test.example.simulation

import gatling.test.example.simulation.SystemPropertiesUtil._

object PerfTestConfig {
  val baseUrl = getAsStringOrElse("baseUrl", "http://localhost:8080")
  val requestPerSecond = getAsDoubleOrElse("requestPerSecond", 10f)
  val durationMin = getAsDoubleOrElse("durationMin", 0.25)
  val meanResponseTimeMs = getAsIntOrElse("meanResponseTimeMs", 500)
  val maxResponseTimeMs = getAsIntOrElse("maxResponseTimeMs", 1000)
}
