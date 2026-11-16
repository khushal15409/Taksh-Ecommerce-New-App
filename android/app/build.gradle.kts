import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: put android/key.properties (NOT in git) next to this project with
//   storePassword=...  keyPassword=...  keyAlias=...  storeFile=/path/to/upload-keystore.jks
// Release builds NEVER fall back to the debug key: if key.properties or the keystore is missing the
// release build stops with a clear error (see the check at the end). Debug/profile builds still use
// the normal debug key.
val keystoreProperties = Properties()
// Looked up in this order, so a build from a clean git export still finds the credentials:
//   1) android/key.properties   2) the file named by env TAKSH_KEY_PROPERTIES   3) ~/.taksh/key.properties
val keystorePropertiesFile: File = listOfNotNull(
    rootProject.file("key.properties"),
    System.getenv("TAKSH_KEY_PROPERTIES")?.takeIf { it.isNotBlank() }?.let { File(it) },
    File(System.getProperty("user.home"), ".taksh/key.properties"),
).firstOrNull { it.isFile } ?: rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

/** Why release signing can't be used, or null when key.properties and the keystore are complete. */
fun releaseSigningProblem(): String? {
    if (!keystorePropertiesFile.exists()) return "key.properties was not found (android/key.properties, \$TAKSH_KEY_PROPERTIES or ~/.taksh/key.properties)"
    val missing = listOf("storePassword", "keyPassword", "keyAlias", "storeFile")
        .filter { keystoreProperties.getProperty(it).isNullOrBlank() }
    if (missing.isNotEmpty()) return "key.properties is missing: ${missing.joinToString(", ")}"
    if (!file(keystoreProperties.getProperty("storeFile")).isFile) {
        return "the keystore file given as storeFile in android/key.properties does not exist"
    }
    return null
}

android {
    namespace = "com.example.taksh_e_commerce"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

        // kotlinOptions {
        //     jvmTarget = "17"
        // }
    
        defaultConfig {
            // Permanent Play Store identity. namespace (Kotlin package / R class) is deliberately left as
            // com.example.taksh_e_commerce: it is independent of applicationId and needs no source move.
            applicationId = "in.takshallinone.app"
            // You can update the following values to match your application needs.
            // For more information, see: https://flutter.dev/to/review-gradle-config.
            minSdk = 24 // flutter.minSdkVersion
            targetSdk = flutter.targetSdkVersion
            versionCode = 1 // flutter.versionCode
            versionName = "1.0.0" // flutter.versionName
        }

    signingConfigs {
        // Only defined when every credential is present; the check at the end of this file turns an
        // incomplete setup into a clear error for release builds.
        if (releaseSigningProblem() == null) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // null (=> unsigned, never debug-signed) when the setup is incomplete; such a build is
            // refused by the check at the end of this file.
            // Only the CI test-APK workflow sets TAKSH_ALLOW_DEBUG_SIGNED_APK=true. It never applies to
            // an App Bundle (the check at the end of this file always refuses a debug-signed AAB).
            signingConfig = signingConfigs.findByName("release")
                ?: if (System.getenv("TAKSH_ALLOW_DEBUG_SIGNED_APK") == "true") signingConfigs.getByName("debug") else null
        }
    }
}

flutter {
    source = "../.."
}

// Firebase push notifications. The Google Services plugin turns google-services.json into the
// app's Firebase configuration, but it FAILS the build when that file has no client for this
// applicationId. So it is applied only when the file is registered for this app. Otherwise the
// same configuration values (src/firebaseFallback/res) are compiled in, so Firebase still starts
// and push works; register this applicationId in Firebase and commit its google-services.json
// to switch to the standard setup.
val applicationIdValue = android.defaultConfig.applicationId
val googleServicesFile = file("google-services.json")
if (googleServicesFile.exists() &&
    Regex("\"package_name\"\\s*:\\s*\"${Regex.escape(applicationIdValue ?: "")}\"")
        .containsMatchIn(googleServicesFile.readText())
) {
    apply(plugin = "com.google.gms.google-services")
} else {
    android.sourceSets.getByName("main").res.srcDir("src/firebaseFallback/res")
    logger.warn("google-services.json is not registered for $applicationIdValue: using the built-in Firebase configuration (src/firebaseFallback)")
}

// Refuse release builds that cannot be signed with the upload key (never use the debug key).
// Exception, explicit opt-in only: a test APK built by the exact tasks assembleRelease/packageRelease
// when TAKSH_ALLOW_DEBUG_SIGNED_APK=true (used by the CI "Build Android APK" workflow). Any App
// Bundle task (bundleRelease, packageReleaseBundle, signReleaseBundle, ...) is refused whenever the
// upload key is not configured, flag or not. Exact task names are matched on purpose: AGP has other
// tasks that merely start with "bundleRelease"/"packageRelease" (e.g. bundleReleaseClassesToRuntimeJar).
gradle.taskGraph.whenReady {
    val names = allTasks.filter { it.project == project }.map { it.name }
    val bundleRequested = names.any { it == "bundleRelease" || (it.contains("Release") && it.endsWith("Bundle")) }
    val apkRequested = names.any { it == "assembleRelease" || it == "packageRelease" }
    val allowDebugApk = System.getenv("TAKSH_ALLOW_DEBUG_SIGNED_APK") == "true"
    val problem = releaseSigningProblem()
    if (problem != null && (bundleRequested || (apkRequested && !allowDebugApk))) {
        throw GradleException("Release signing is not configured: $problem. Refusing to build a release without the upload key.")
    }
}

// .env is bundled into the app as a Flutter asset, so a release build must never carry anything but
// the client-side keys listed here (no FCM credentials, service-account paths, DB or APP_KEY values).
// Only key NAMES are reported, never values.
gradle.taskGraph.whenReady {
    val names = allTasks.filter { it.project == project }.map { it.name }
    val releaseBuild = names.any { it == "bundleRelease" || it == "assembleRelease" }
    val envFile = rootProject.file("../.env")
    if (releaseBuild && envFile.isFile) {
        val allowed = setOf("GOOGLE_PLACES_API_KEY")
        val extra = envFile.readLines()
            .map { it.trim() }
            .filter { it.isNotEmpty() && !it.startsWith("#") && it.contains("=") }
            .map { it.substringBefore("=").trim().removePrefix("export ").trim() }
            .filter { it !in allowed }
        if (extra.isNotEmpty()) {
            throw GradleException(
                ".env would be bundled into the app but contains non client-side keys: ${extra.joinToString(", ")}. " +
                    "Remove them (allowed: ${allowed.joinToString(", ")}) before a release build."
            )
        }
    }
}
