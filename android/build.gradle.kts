allprojects {
    repositories {
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
    
    // Configure JVM compatibility for all subprojects
    afterEvaluate {
        // Set missing namespace for legacy on_audio_query Android library to satisfy AGP 8+
        if (project.name == "on_audio_query_android") {
            extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
                namespace = "com.lucasjosino.on_audio_query"
            }
        }

        // Set missing namespace for legacy share_plus Android library to satisfy AGP 8+
        if (project.name == "share_plus") {
            extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
                namespace = "dev.fluttercommunity.plus.share"
            }
        }

        // Configure Android projects
        extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
        
        // Configure Kotlin compilation
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
        
        // Configure Java compilation
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
