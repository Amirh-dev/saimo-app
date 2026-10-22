allprojects {
    repositories {
        // Google Maven (dl.google.com) answers 404 to requests from Iran, even through
        // the proxy, so AndroidX comes from mirrors first. google() stays as a fallback.
        maven { url = uri("https://maven.myket.ir") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
