import org.gradle.api.file.Directory
import java.lang.reflect.Method

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Put all build outputs under ../../build (Flutter style)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Put each subproject's build output under the shared build dir
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Some Flutter builds expect :app evaluated first
    project.evaluationDependsOn(":app")

    // Force specific AndroidX test libs (your existing pin)
    configurations.all {
        resolutionStrategy {
            force(
                "androidx.test:runner:1.5.2",
                "androidx.test:rules:1.5.0",
                "androidx.test.ext:junit:1.1.5",
                "androidx.test.espresso:espresso-core:3.5.1"
            )
        }
    }

    // ---- Force compileSdk for ALL Android modules (app + plugins) ----
    fun tryInvoke(m: Method, receiver: Any, arg: Any): Boolean {
        return try {
            m.invoke(receiver, arg)
            true
        } catch (_: Throwable) {
            false
        }
    }

    fun forceCompileSdk(androidExt: Any, sdkInt: Int) {
        val methods = androidExt.javaClass.methods

        // AGP variants: setCompileSdkVersion(x) or compileSdkVersion(x)
        val m = methods.firstOrNull {
            (it.name == "setCompileSdkVersion" || it.name == "compileSdkVersion") && it.parameterTypes.size == 1
        } ?: return

        // Try common parameter types in order
        // 1) Int
        if (m.parameterTypes[0] == Int::class.javaPrimitiveType || m.parameterTypes[0] == Int::class.javaObjectType) {
            if (tryInvoke(m, androidExt, sdkInt)) return
        }

        // 2) String like "36" or "android-36"
        if (m.parameterTypes[0] == String::class.java) {
            if (tryInvoke(m, androidExt, sdkInt.toString())) return
            if (tryInvoke(m, androidExt, "android-$sdkInt")) return
        }

        // 3) Fallback: just try a couple anyway (some reflection bridges accept it)
        tryInvoke(m, androidExt, sdkInt)
        tryInvoke(m, androidExt, sdkInt.toString())
        tryInvoke(m, androidExt, "android-$sdkInt")
    }

    // Configure when Android plugins are applied (no afterEvaluate)
    plugins.withId("com.android.library") {
        extensions.findByName("android")?.let { forceCompileSdk(it, 36) }
    }

    plugins.withId("com.android.application") {
        extensions.findByName("android")?.let { forceCompileSdk(it, 36) }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
