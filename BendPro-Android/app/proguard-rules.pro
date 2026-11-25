# ProGuard & R8 rules for BendPro

# Keep Kotlin Serialization classes and serializers
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.SerializationCoreKt
-keepclassmembers class * {
    *** Companion;
}
-keepclasseswithmembers class * {
    kotlinx.serialization.KSerializer serializer(...);
}
-keepclassmembers class * implements kotlinx.serialization.KSerializer {
    java.lang.Object deserialize(...);
    void serialize(...);
}
-keep,allowobfuscation,allowshrinking class * {
    <init>(...);
}

# Preserve core calculation and state models
-keep class com.bendpro.core.** { *; }
-keep class com.bendpro.data.** { *; }

# Compose rules
-keep class androidx.compose.** { *; }
