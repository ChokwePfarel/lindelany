
import java.util.Properties
import java.io.FileInputStream


val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.pfarelo.lindelani"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    signingConfigs {
        //for keystore
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    compileOptions {
        // Enable desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.pfarelo.lindelani"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        //for keystore
        //enabled Code Shrinking and Obfuscation, which are essential for making your app smaller and
        // harder to reverse-engineer.
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true // remove unused code
            isShrinkResources = true //remove unused resouse fil
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            ) // performs extra optimizations at the bytecode level.
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.android.support:support-annotations:28.0.0")

    // Required for desugaring(related to notification)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    //App check
    implementation("com.google.firebase:firebase-appcheck-debug:17.1.2")
    implementation(platform("com.google.firebase:firebase-bom:34.0.0")) // Or the latest BoM version
}

flutter {
    source = "../.."
}
