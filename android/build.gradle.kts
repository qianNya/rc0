fun RepositoryHandler.configureCnMirrors() {
    maven { url = uri("https://maven.aliyun.com/repository/google") }
    maven { url = uri("https://maven.aliyun.com/repository/public") }
    maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
    maven { url = uri("https://maven.aliyun.com/repository/central") }
    google()
    mavenCentral()
}

allprojects {
    repositories {
        configureCnMirrors()
    }
}

subprojects {
    buildscript {
        repositories {
            configureCnMirrors()
        }
    }
    repositories {
        configureCnMirrors()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    if (project.name == "video_thumbnail") {
        project.beforeEvaluate {
            val buildFile = project.file("build.gradle")
            if (!buildFile.exists()) return@beforeEvaluate

            val patched = """
group 'xyz.justsoft.video_thumbnail'
version '1.0-SNAPSHOT'

apply plugin: 'com.android.library'

android {
    compileSdkVersion 36
    namespace 'xyz.justsoft.video_thumbnail'

    defaultConfig {
        minSdkVersion 24
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
    lintOptions {
        disable 'InvalidPackage'
    }
}
""".trimIndent()

            buildFile.writeText(patched)
        }
    }
}

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
            compileSdkVersion(36)
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
