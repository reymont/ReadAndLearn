Gradle - Plugin: org.sonarqube https://plugins.gradle.org/plugin/org.sonarqube

Build script snippet for plugins DSL for Gradle 2.1 and later:

plugins {
  id "org.sonarqube" version "2.6.2"
}
Build script snippet for use in older Gradle versions or where dynamic configuration is required:

buildscript {
  repositories {
    maven {
      url "https://plugins.gradle.org/m2/"
    }
  }
  dependencies {
    classpath "org.sonarsource.scanner.gradle:sonarqube-gradle-plugin:2.6.2"
  }
}

apply plugin: "org.sonarqube"