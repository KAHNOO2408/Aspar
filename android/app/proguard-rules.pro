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

# General
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
-optimizationpasses 5
-verbose
