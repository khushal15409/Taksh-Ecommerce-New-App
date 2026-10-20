plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
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

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Firebase push notifications: the Google Services plugin turns google-services.json into the
// app's Firebase configuration and FAILS the build when that file has no client for this
// applicationId. So it is applied only when the file is registered for this app; otherwise
// the app builds and runs as before, without push (see PushNotificationService).
val applicationIdValue = android.defaultConfig.applicationId
val googleServicesFile = file("google-services.json")
if (googleServicesFile.exists() &&
    Regex("\"package_name\"\\s*:\\s*\"${Regex.escape(applicationIdValue ?: "")}\"")
        .containsMatchIn(googleServicesFile.readText())
) {
    apply(plugin = "com.google.gms.google-services")
} else {
    logger.warn("Push notifications disabled: app/google-services.json is missing or not registered for $applicationIdValue")
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}
