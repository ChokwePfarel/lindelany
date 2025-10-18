buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Updated Gradle plugin for better compatibility
        classpath("com.android.tools.build:gradle:8.13.0")
        classpath("com.google.gms:google-services:4.4.3")
        // Updated Kotlin plugin for modern Gradle and Android versions
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")

    }
}

// This block redirects the build output directory for the root project
// and all subprojects (like your app module) to the parent 'build' folder.
// This is likely what the Flutter tool expects.
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
