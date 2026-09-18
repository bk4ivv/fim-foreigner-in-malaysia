import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val isReleaseBuild = gradle.startParameter.taskNames.any { taskName ->
    taskName.contains("Release", ignoreCase = true)
}

fun requiredProperty(name: String): String {
    return keystoreProperties.getProperty(name)?.takeIf { it.isNotBlank() }
        ?: throw GradleException("Missing '$name' in ${keystorePropertiesFile.path}.")
}

fun requiredEnvironment(name: String): String {
    return System.getenv(name)?.takeIf { it.isNotBlank() }
        ?: throw GradleException("Missing signing environment variable '$name'.")
}

if (isReleaseBuild && !keystorePropertiesFile.exists()) {
    throw GradleException(
        "Release signing requires ${keystorePropertiesFile.path}. " +
            "Create the file with the upload keystore settings before building a release artifact."
    )
}

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

if (isReleaseBuild && keystorePropertiesFile.exists()) {
    requiredProperty("keyAlias")
    requiredProperty("storeFile")
    requiredEnvironment("FIM_KEYSTORE_PASSWORD")
    requiredEnvironment("FIM_KEY_PASSWORD")
}

android {
    namespace = "com.expatstatuschecker.expat_status_checker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.expatstatuschecker.expat_status_checker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("releaseUpload") {
                keyAlias = keystoreProperties.getProperty("keyAlias", "")
                keyPassword = System.getenv("FIM_KEY_PASSWORD") ?: ""
                storeFile = file(keystoreProperties.getProperty("storeFile", ""))
                storePassword = System.getenv("FIM_KEYSTORE_PASSWORD") ?: ""
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("releaseUpload")
            } else {
                // Release tasks fail explicitly above; this branch only keeps debug/development
                // Gradle configuration usable when no upload key is present.
                signingConfigs.getByName("debug")
            }
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
