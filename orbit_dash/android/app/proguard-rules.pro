# Keep rules for Orbit Dash release builds (R8/ProGuard).
# The Google Mobile Ads SDK and Flutter ship their own consumer rules;
# these cover the few things that still get stripped in fully-shrunk builds.

# Google Mobile Ads / UMP
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.ump.** { *; }

# Flutter deferred components stubs referenced by the embedding.
-dontwarn com.google.android.play.core.**
