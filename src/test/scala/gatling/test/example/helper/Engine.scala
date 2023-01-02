package gatling.test.example.helper

import io.gatling.app.Gatling
import io.gatling.core.config.GatlingPropertiesBuilder

object Engine {
  def start(): Unit = {
    val props = new GatlingPropertiesBuilder
    props.resourcesDirectory(IDEPathHelper.mavenResourcesDirectory.toString)
    props.resultsDirectory(IDEPathHelper.resultsDirectory.toString)
    props.binariesDirectory(IDEPathHelper.mavenBinariesDirectory.toString)
    Gatling.fromMap(props.build)
  }

  def main(args: Array[String]) = Engine.start
}
