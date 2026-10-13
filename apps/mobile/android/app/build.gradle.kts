plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties

// Load release signing config from android/key.properties.
// Create key.properties from key.properties.example and fill in real values
// before building a signed release APK.
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    val raw = keyPropertiesFile.readText(Charsets.UTF_8).removePrefix("\uFEFF")
    keyProperties.load(raw.reader())
}

fun signingString(props: Properties, key: String): String =
    props.getProperty(key)?.trim().orEmpty().ifEmpty {
        error("Missing or empty '$key' in ${keyPropertiesFile.path}")
    }

android {
    namespace = "com.moozhayil.moozhayil"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.moozhayil.moozhayil"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Required for flutter_secure_storage on API 23+
        multiDexEnabled = true
    }

    signingConfigs {
        if (keyPropertiesFile.exists()) {
            create("release") {
                keyAlias = signingString(keyProperties, "keyAlias")
                keyPassword = signingString(keyProperties, "keyPassword")
                storeFile = rootProject.file(signingString(keyProperties, "storeFile"))
                storePassword = signingString(keyProperties, "storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keyPropertiesFile.exists())
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
        debug {
            applicationIdSuffix = ".debug"
            isDebuggable = true
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
