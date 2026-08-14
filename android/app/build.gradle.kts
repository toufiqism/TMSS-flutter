import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing credentials, loaded from android/key.properties — which is gitignored
// and must never be committed. See key.properties.example for the expected keys and
// README "Release signing" for how to create the keystore.
//
// Absent on purpose for most checkouts: CI and other developers can still build and run
// release locally, falling back to debug signing (see the release buildType below). What
// that fallback must never do is silently produce an artifact someone then uploads, so
// it warns loudly and `verifyReleaseSigning` fails the build when it matters.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseSigning = keystoreProperties.getProperty("storeFile") != null

android {
    namespace = "com.banglatrac.tmss"
    // Pinned rather than inherited from flutter.compileSdkVersion: flutter_secure_storage
    // ships AAR metadata requiring compileSdk 37, and the Flutter SDK's default is lower,
    // which fails :app:checkDebugAarMetadata. Raising compileSdk only widens the APIs
    // available at compile time — minSdk and targetSdk below are unaffected.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.banglatrac.tmss"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 30
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                // Resolved relative to android/, so key.properties can point at a
                // keystore kept outside the repo entirely.
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")

                // Signature schemes, set explicitly rather than left to defaults.
                //
                // v1 (JAR signing) is off: it is the weak, slow scheme and is only
                // needed below API 24, well under this app's minSdk of 30.
                //
                // v3 is on because it carries a signing-certificate *lineage* — the
                // mechanism that lets a published app rotate to a new key later. It has
                // to be present from the first shipped build; an app released on v2
                // alone can never rotate its key afterwards.
                enableV1Signing = false
                enableV2Signing = true
                enableV3Signing = true
            }
        }
    }

    buildTypes {
        release {
            // Real key when key.properties is present; debug key otherwise so that
            // `flutter run --release` still works on a fresh checkout. A debug-signed
            // build is fine to run and impossible to distribute — Play rejects it — and
            // `verifyReleaseSigning` below stops one leaving the machine by accident.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "\n⚠️  android/key.properties not found — signing release with the " +
                        "DEBUG key.\n    This artifact cannot be distributed. See README " +
                        "\"Release signing\".\n",
                )
                signingConfigs.getByName("debug")
            }

            // R8 — the only shrinker AGP ships, so `isMinifyEnabled` *is* R8; there is
            // no separate switch to turn on. It strips unreachable Java/Kotlin classes
            // and obfuscates what remains. It does not touch the Dart code, which is
            // already AOT-compiled into libapp.so and is the bulk of the APK.
            isMinifyEnabled = true

            // Drops unreferenced resources (drawables, layouts, strings) from the
            // Flutter template and from plugin AARs. Requires isMinifyEnabled, because
            // it uses R8's reachability analysis to decide what a resource is still
            // referenced from.
            isShrinkResources = true

            proguardFiles(
                // -optimize: the default file with optimisation passes enabled. AGP
                // recommends it over plain proguard-android.txt for R8.
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
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

// Guard against shipping a debug-signed release.
//
// The fallback above is a convenience for local `flutter run --release`; it is a hazard
// the moment an artifact is uploaded. Run this in CI (or before any manual upload) to
// turn "silently signed with the debug key" into a build failure:
//
//     ./gradlew verifyReleaseSigning
tasks.register("verifyReleaseSigning") {
    doLast {
        check(hasReleaseSigning) {
            "Release signing is not configured: android/key.properties is missing, so " +
                "release builds are signed with the DEBUG key and cannot be distributed."
        }
    }
}
