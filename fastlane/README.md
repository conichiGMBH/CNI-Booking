fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios release
```
fastlane ios release
```
Release a new version of the CNI-Itineraries. Uploading a new release to a GitHub and CocoaPods trunk

Before doing so don't forget to follow check all steps in RELEASING.md
### ios podspec_push
```
fastlane ios podspec_push
```
Push podspecs to conichi specs repo

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
