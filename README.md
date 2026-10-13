# Learn with Cards

Learn with Cards is an iOS SwiftUI app for studying vocabulary with cards and categories. It loads category and card JSON from separate configurable language data URLs, stores downloaded content locally, and keeps imported word sets across app launches. Word sets can be imported from a text file, URL, pasted text, or the iOS Share extension. See [the architecture overview](DOCS/architecture.md) for the component map.

## Project

The Xcode project and shared scheme are under `Learner/`. Build settings, dependencies, targets, and test configuration are described in [the architecture overview](DOCS/architecture.md).

## Build and test

Use Xcode with the `Learner` scheme in `Learner/Learner.xcodeproj`:

```sh
xcodebuild -project Learner/Learner.xcodeproj -scheme Learner -destination 'generic/platform=iOS Simulator' build
```

To run the scheme's tests, select an installed simulator supported by the test targets:

```sh
xcodebuild -project Learner/Learner.xcodeproj -scheme Learner -destination 'platform=iOS Simulator,name=<installed simulator name>' test
```

The test command requires an installed simulator and resolved Swift Package Manager dependencies. Current test coverage and test-scheme limitations are tracked in [behavior records](DOCS/behavior/README.md).

## App Store releases

The Fastlane iOS release lane loads the repository-root `.env` file and authenticates with an App Store Connect API key. Set `APP_STORE_CONNECT_API_KEY_KEY_ID`, `APP_STORE_CONNECT_API_KEY_ISSUER_ID`, and `APP_STORE_CONNECT_API_KEY_KEY_FILEPATH` there; the `.p8` key file can live in the Git-ignored `fastlane/` directory. Both `.env` and the key file are excluded from Git and must not be committed. The API key must have a role allowed to upload builds and submit apps for review. Set the app and Share extension `MARKETING_VERSION` to a new, higher App Store version whose pre-release train is open; App Store Connect closes a train after that version is approved. The lane increments only the build number. Release uploads only the English What's New note configured in [fastlane/Fastfile](fastlane/Fastfile), leaving other store metadata untouched. If a submission stops after upload, `bundle exec fastlane ios submit_uploaded_build` submits the existing IPA without uploading it again. The lane uses Xcode automatic signing for the app and Share extension; Xcode must be signed in to the Developer team with signing access for both targets and the App Groups capability. See [release automation behavior](DOCS/behavior/release.md) for the signing requirements and limitations.

## Documentation

- [Architecture](DOCS/architecture.md)
- [Backlog](DOCS/backlog.md)
- [Behavior records and template](DOCS/behavior/README.md)
- [Architecture decision and constraints](DOCS/decisions/data-boundaries.md)
- [Agent instructions](AGENTS.md)
