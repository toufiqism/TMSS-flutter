# R8 keep rules for the release build.
#
# Deliberately short. Every AAR ships its own consumer rules and AGP merges them
# automatically, so the Flutter engine, flutter_secure_storage and shared_preferences
# already protect what they need. Adding blanket `-keep class **` rules here would
# silently undo most of the shrinking this file exists to enable.
#
# Only add a rule when a release build actually misbehaves, and say which symbol and
# which failure it fixes.

# Flutter's embedding is entered from native code and via reflection in a few places.
# The engine AAR covers this, but the deferred-components classes are referenced only
# from generated code and R8 warns about them on projects that do not use them.
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication

# Play Core is only present when deferred components / split installs are used. This app
# does not use them, so the references are unreachable rather than missing.
-dontwarn com.google.android.play.core.**

# Keep annotations and generic signatures. R8 strips these by default under
# proguard-android-optimize, and losing them breaks any runtime type inspection —
# including the Kotlin metadata some plugins read.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod

# Line numbers in release stack traces. Without this a crash report from the field
# points at nothing useful; SourceFile is renamed rather than kept so it leaks no paths.
-keepattributes SourceFile, LineNumberTable
-renamesourcefileattribute SourceFile
