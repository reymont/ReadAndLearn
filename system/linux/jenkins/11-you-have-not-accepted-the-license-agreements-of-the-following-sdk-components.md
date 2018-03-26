# https://stackoverflow.com/questions/39760172/you-have-not-accepted-the-license-agreements-of-the-following-sdk-components

You can install and accept the license of the SDK & tools via 2 ways:

1. Open the Android SDK Manager GUI via command line

Open the Android SDK manager via the command line using:

# Android SDK Tools 25.2.3 and lower - Open the Android SDK GUI via the command line
cd ~/Library/Android/sdk/tools && ./android

# 'Android SDK Tools' 25.2.3 and higher - `sdkmanager` is located in android_sdk/tools/bin/.
cd ~/Library/Android/sdk/tools/bin && ./sdkmanager
View more details on the new sdkmanager.

Select and install the required tools. (your location may be different)
2. Install and accept android license via command line:

Update the packages via command line, you'll be presented with the terms and conditions which you'll need to accept.

- Install or update to the latest version

This will install the latest platform-tools at the time you run it.

# Android SDK Tools 25.2.3 and lower. Install the latest `platform-tools` for android-25
android update sdk --no-ui --all --filter platform-tools,android-25,extra-android-m2repository

# Android SDK Tools 25.2.3 and higher
sdkmanager --update
- Install a specific version (25.0.1, 24.0.1, 23.0.1)

You can also install a specific version like so:

# Build Tools 23.0.1, 24.0.1, 25.0.1
android update sdk --no-ui --all --filter build-tools-25.0.1,android-25,extra-android-m2repository
android update sdk --no-ui --all --filter build-tools-24.0.1,android-24,extra-android-m2repository
android update sdk --no-ui --all --filter build-tools-23.0.1,android-23,extra-android-m2repository
# Alter the versions as required                      ↑               ↑

# -u --no-ui  : Updates from command-line (does not display the GUI)
# -a --all    : Includes all packages (such as obsolete and non-dependent ones.)
# -t --filter : A filter that limits the update to the specified types of
#               packages in the form of a comma-separated list of
#               [platform, system-image, tool, platform-tool, doc, sample,
#               source]. This also accepts the identifiers returned by
#               'list sdk --extended'.

# List version and description of other available SDKs and tools
android list sdk --extended
sdkmanager --list