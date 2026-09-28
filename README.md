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

The Fastlane iOS release lane loads the repository-root `.env` file. Set `FASTLANE_PASSWORD` there before running `bundle exec fastlane ios release`. The `.env` file is excluded from Git so account credentials stay local; do not commit it.

## Documentation

- [Architecture](DOCS/architecture.md)
- [Backlog](DOCS/backlog.md)
- [Behavior records and template](DOCS/behavior/README.md)
- [Architecture decision and constraints](DOCS/decisions/data-boundaries.md)
- [Agent instructions](AGENTS.md)
