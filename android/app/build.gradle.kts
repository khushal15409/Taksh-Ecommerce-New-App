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
// Without that file the build signs with the debug key exactly as before (fine for local runs, rejected by Google Play).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
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
            // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
            applicationId = "com.example.taksh_e_commerce"
            // You can update the following values to match your application needs.
            // For more information, see: https://flutter.dev/to/review-gradle-config.
            minSdk = 24 // flutter.minSdkVersion
            targetSdk = flutter.targetSdkVersion
            versionCode = 1 // flutter.versionCode
            versionName = "1.0.0" // flutter.versionName
        }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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
