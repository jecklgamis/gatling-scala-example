package gatling.test.example.helper

import gatling.test.example.simulation.PerfTestConfig
import io.gatling.app.Gatling
import io.gatling.core.config.GatlingPropertiesBuilder

object Engine {
  def start(): Unit = {
    println(s"Target app base url : ${PerfTestConfig.baseUrl}")
    val props = new GatlingPropertiesBuilder
    props.dataDirectory(IDEPathHelper.dataDirectory.toString)
    props.resultsDirectory(IDEPathHelper.resultsDirectory.toString)
    props.bodiesDirectory(IDEPathHelper.bodiesDirectory.toString)
    props.binariesDirectory(IDEPathHelper.mavenBinariesDirectory.toString)
    Gatling.fromMap(props.build)
  }

  def main(args: Array[String]) = Engine.start
}
