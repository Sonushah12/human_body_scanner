#!/usr/bin/env bash
# Source this in the managed cloud workspace. Local development can use Flutter
# on PATH normally. Keep SDK state/caches in writable, retained workspace paths.
export ANATOMORPH_TOOLCHAINS=/workspace/.toolchains
export ANATOMORPH_FLUTTER="$ANATOMORPH_TOOLCHAINS/flutter-3.44.4"
export PATH="$ANATOMORPH_FLUTTER/bin:$PATH"
export PUB_CACHE=/workspace/.pub-cache
export XDG_CONFIG_HOME="$ANATOMORPH_TOOLCHAINS/config"
export XDG_CACHE_HOME="$ANATOMORPH_TOOLCHAINS/cache"
export ANALYZER_STATE_LOCATION_OVERRIDE="$ANATOMORPH_TOOLCHAINS/analyzer"
export CI=true
export DASH__SUPPRESS_ANALYTICS=true
export ANDROID_HOME="$ANATOMORPH_TOOLCHAINS/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_USER_HOME="$ANATOMORPH_TOOLCHAINS/android-user"
export GRADLE_USER_HOME=/workspace/.gradle
export JAVA_HOME="$ANATOMORPH_TOOLCHAINS/jdk-21"
export PATH="$JAVA_HOME/bin:$PATH"
