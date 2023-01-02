package gatling.test.example.helper

import java.nio.file.Paths


object IDEPathHelper {
  val gatlingConfUrl = Paths.get(getClass.getClassLoader.getResource("gatling.conf").toURI)
  val projectRootDir = gatlingConfUrl.getParent.getParent.getParent

  val mavenSourcesDirectory = projectRootDir.resolve("src").resolve("main").resolve("scala")
  val mavenResourcesDirectory = mavenSourcesDirectory.resolve("resources")

  val mavenTargetDirectory = projectRootDir.resolve("target")
  val mavenBinariesDirectory = mavenTargetDirectory.resolve("classes")
  val resultsDirectory = mavenTargetDirectory.resolve("gatling")

}
