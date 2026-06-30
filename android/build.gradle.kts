fun RepositoryHandler.configureCnMirrors() {
    maven { url = uri("https://maven.aliyun.com/repository/google") }
    maven { url = uri("https://maven.aliyun.com/repository/public") }
    maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
    maven { url = uri("https://maven.aliyun.com/repository/central") }
}

allprojects {
    repositories {
        configureCnMirrors()
    }
}

subprojects {
    if (project.name == "flutter_gl") {
        val flutterGlAarDir = project.file("libs/aars")
        rootProject.allprojects {
            repositories {
                flatDir {
                    dirs(flutterGlAarDir)
                }
            }
        }
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
    beforeEvaluate {
        val buildFile = project.file("build.gradle")
        if (buildFile.exists() && buildFile.readText().contains("jcenter()")) {
            buildFile.writeText(buildFile.readText().replace("jcenter()", "mavenCentral()"))
        }
    }

    pluginManager.withPlugin("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            if (namespace.isNullOrBlank()) {
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    Regex("""package="([^"]+)"""")
                        .find(manifestFile.readText())
                        ?.groupValues
                        ?.get(1)
                        ?.let { namespace = it }
                }
            }
        }
    }
}

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

    if (project.name == "flutter_gl") {
        project.beforeEvaluate {
            val buildFile = project.file("build.gradle")
            if (!buildFile.exists()) return@beforeEvaluate

            val patched = """
group 'com.futouapp.flutter_gl.flutter_gl'
version '1.0-SNAPSHOT'

buildscript {
    ext.kotlin_version = '2.3.20'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.9.1'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:${'$'}kotlin_version"
    }
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    namespace 'com.futouapp.flutter_gl.flutter_gl'
    compileSdkVersion 36

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    defaultConfig {
        minSdkVersion 24
    }
    lintOptions {
        disable 'InvalidPackage'
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:${'$'}kotlin_version"

    implementation 'androidx.appcompat:appcompat:1.3.0'
    implementation 'com.google.android.material:material:1.3.0'

    implementation(name:'threeegl', ext:'aar')
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
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
