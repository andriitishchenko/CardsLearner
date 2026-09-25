# Architecture

The repository builds an iOS app and a text import app extension from `Learner/Learner.xcodeproj`. The main app is SwiftUI; its app entry point assembles the local and remote data sources in `LearnerApp` and `AppIntent` coordinates application loading, navigation, settings, and imports.

```text
SwiftUI screens and view models
              |
           AppIntent
              |
       Domain use cases
       /             \
local repository   remote repository     settings repository
       |                  |                     |
Core Data source     HTTP API client         UserDefaults
```

## Components

- **Presentation** (`Learner/Learner/Presentation/`) contains SwiftUI screens, reusable views, view models, and error presentation.
- **App coordination** (`AppIntent.swift`, `LearnerApp.swift`) connects the UI to use cases and data sources, coordinates local-first loading and remote refresh, and handles imported file URLs.
- **Domain** (`Learner/Learner/Domain/`) defines card, category, and settings models, repository protocols, errors, and use cases for remote aggregation, local persistence conversion, and user settings.
- **Data** (`Learner/Learner/Data/`) implements HTTP requests and remote JSON decoding, repository adapters, Core Data storage, and UserDefaults settings storage.
- **Import extension** (`Learner/LearnerImport/`) provides the iOS share/action extension that accepts text or files. The app handles imported files and can also receive them through the `lrnwcards` URL scheme and the shared app group configured in its entitlements.
- **Resources and configuration** include the Core Data model, asset catalogs, app and extension property lists, entitlements, and Xcode scheme.

The remote API expects `categories.json` and `cards.json` at each configured language data URL. Category data supplies category metadata; card data supplies language-specific card content. The aggregation use case combines the configured origin and study-language card sets by card ID and assigns cards to categories. Local copies are mapped to Core Data group and card entities. See [the durable layer boundary](decisions/data-boundaries.md) for constraints that changes should preserve.

## Build and tests

The project is an Xcode project with the shared `Learner` scheme. Swift Package Manager resolves Firebase SDK products and Google Mobile Ads. The main app deployment target is iOS 16.0, and the import extension deployment target is iOS 18.0. Build and test command templates are in the [README](../README.md#build-and-test).

The project defines `LearnerTests` and `LearnerUITests` targets. The shared scheme also references a `LearnerUITests1` testable that is not defined as a project target, so scheme test execution needs verification. Existing unit coverage includes API response decoding, non-success HTTP status handling, and decoding failures. See [API and app behavior](behavior/app.md) for coverage details and known verification limitations.
