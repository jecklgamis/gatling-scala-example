package gatling.test.example.simulation

import scala.sys.SystemProperties

object SystemPropertiesUtil {
  val systemProperties = new SystemProperties

  def getAsIntOrElse(property: String, default: Int): Int = {
    systemProperties.getOrElse(property, default).toString.toInt
  }

  def getAsStringOrElse(property: String, default: String): String = {
    systemProperties.getOrElse(property, default)
  }

  def getAsBooleanOrElse(property: String, default: Boolean): Boolean = {
    systemProperties.getOrElse(property, default).toString().toBoolean
  }

  def getAsDoubleOrElse(property: String, default: Double): Double = {
    systemProperties.getOrElse(property, default).toString().toDouble
  }

}
