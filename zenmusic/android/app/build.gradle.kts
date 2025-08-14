plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.zenyfh.zenmusic"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.zenyfh.zenmusic"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0",
                "META-INF/*.kotlin_module",
                "META-INF/INDEX.LIST",
                "META-INF/io.netty.versions.properties",
                "yts-version.txt"
            )
        }
    }
}

repositories {
    mavenCentral()
    maven { url = uri("https://jitpack.io") } // For lavasrc dependencies
    maven { url = uri("https://maven.topi.wtf/releases") } // For lavasrc releases
    maven { url = uri("https://maven.lavalink.dev/snapshots") } // For lavaplayer SNAPSHOT
    maven { url = uri("https://maven.lavalink.dev/releases") } // For stable lavalink/youtube
    // You likely don't need these unless using JDA or other dv8tion libs:
    // maven { url = uri("https://m2.dv8tion.net/releases") }
    // jcenter() - Deprecated and mostly unnecessary now
}

dependencies {
    implementation("dev.arbjerg:lavaplayer:66ae62fd8e0fb9c97e0db020b06b91e05f4a6763-SNAPSHOT") {
        exclude(group = "com.sedmelluq", module = "lavaplayer")
    }
    implementation("dev.lavalink.youtube:v2:1.13.4") // This includes common functionality
}

flutter {
    source = "../.."
}
