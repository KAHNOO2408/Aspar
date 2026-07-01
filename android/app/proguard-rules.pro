# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Provider
-keep class provider.** { *; }
-keep class **provider.** { *; }

# Hive
-keep class com.hive.** { *; }
-keep class hive.** { *; }

# Encryption
-keep class encrypt.** { *; }
-keep class pointycastle.** { *; }

# Play Core Library
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Local Auth
-keep class io.flutter.plugins.local_auth.** { *; }

# Secure Storage
-keep class com.ryanheise.fluttersecurestorage.** { *; }

# General
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
-optimizationpasses 5
-verbose
-dontobfuscate
