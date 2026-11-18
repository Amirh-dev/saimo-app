# flutter_local_notifications stores scheduled notifications as JSON through
# Gson TypeToken. R8 full mode strips the generic signatures Gson needs, which
# fails in release with "Missing type parameter." on every cancel/schedule.
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type
-keep class com.dexterous.** { *; }
