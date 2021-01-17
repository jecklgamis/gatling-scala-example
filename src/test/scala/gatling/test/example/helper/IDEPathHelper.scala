package gatling.test.example.helper

import java.nio.file.Paths

import io.gatling.commons.shared.unstable.util.PathHelper._

object IDEPathHelper {
  val gatlingConfUrl = Paths.get(getClass.getClassLoader.getResource("gatling.conf").toURI)
  val projectRootDir = gatlingConfUrl.ancestor(3)

  val mavenSourcesDirectory = projectRootDir / "src" / "main" / "scala"
  val mavenResourcesDirectory = projectRootDir / "src" / "main" / "resources"
  val mavenTargetDirectory = projectRootDir / "target"
  val mavenBinariesDirectory = mavenTargetDirectory / "classes"

  val dataDirectory = mavenResourcesDirectory / "data"
  val bodiesDirectory = mavenResourcesDirectory / "bodies"

  val recorderOutputDirectory = mavenSourcesDirectory
  val resultsDirectory = mavenTargetDirectory / "results"

}
