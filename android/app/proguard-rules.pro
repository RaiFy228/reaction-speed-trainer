# Add this global rule
-keepattributes Signature

# Protect all models in the package lib.models
-keep class lib.models.** { *; }

# Protect Firebase-related classes
-keep class com.google.firebase.** { *; }