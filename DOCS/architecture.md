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

- **Presentation** (`Learner/Learner/Presentation/`) contains SwiftUI screens, reusable views, view models, and error presentation. Route views retain their screen-specific view models as state objects across unrelated app-state updates. Both quiz directions use a shared view-model base for card sequencing, choices, scoring, incorrect-attempt details, and completion review; each direction configures its question and answer fields.
- **Navigation presentation** (`Learner/Learner/Presentation/Navigation/`) isolates the single-column container and the split-view/stack container. `MainView` selects the single-column container on compact widths and the split view on regular widths. On iOS 16 and later in regular width, the split-view detail column binds its `NavigationStack` to `AppIntent.navigationPath`, so native Back navigation pops one destination at a time. On compact widths and iOS 15, the single-column container presents one route at a time and its Back action pops the same path. Selecting a main-list category starts from Categories; selecting an imported set continues from Imported words. Shared content renders every route in both containers.
- **App coordination** (`AppIntent.swift`, `LearnerApp.swift`) connects the UI to use cases and data sources, coordinates local-first loading and remote refresh, and saves imported word sets, optional display names, and dates in UserDefaults. The imports screen accepts files, text URLs, and pasted text; the Share extension continues to hand off files through the app group.
- **Domain** (`Learner/Learner/Domain/`) defines card, category, and settings models, repository protocols, errors, and use cases for remote aggregation, local persistence conversion, and user settings.
- **Data** (`Learner/Learner/Data/`) implements HTTP requests and remote JSON decoding, repository adapters, Core Data storage, and UserDefaults settings storage.
- **Import extension** (`Learner/LearnerImport/`) provides the iOS share/action extension that accepts text or files. Its word-pair parser is shared with the main app. The app handles imported files and can also receive them through the `lrnwcards` URL scheme and the shared app group configured in its entitlements.
- **Resources and configuration** include the Core Data model, asset catalogs, app and extension property lists, entitlements, and Xcode scheme.

The remote API expects `categories.json` and `cards.json` at each configured language data URL. Category data supplies category metadata; card data supplies language-specific card content. The aggregation use case combines the configured origin and study-language card sets by card ID and assigns cards to categories. Local copies are mapped to Core Data group and card entities. See [the durable layer boundary](decisions/data-boundaries.md) for constraints that changes should preserve.

## Build and tests

The project is an Xcode project with the shared `Learner` scheme. All Swift targets use Swift 6 language mode and declare an iOS 15.0 deployment target. The main app links Google Mobile Ads and Google User Messaging Platform from their Swift Package Manager repositories, each with an up-to-next-major version requirement; each workspace records its resolved package graph in `Package.resolved`. Fastlane Ruby tooling is declared in `Gemfile` and locked at 2.240.1 in `Gemfile.lock`. `MainView` uses a single-column `NavigationView` with a path-aware Back action on iOS 15 and in compact size classes, and `NavigationSplitView` with a path-bound `NavigationStack` on iOS 16 and later in regular size classes. Both containers use the same category, import, and app-screen views. The current Xcode XCTest and UI automation libraries are built for iOS 17.0. Build and test command templates are in the [README](../README.md#build-and-test).

The project and shared scheme define `LearnerTests` and `LearnerUITests` targets. Existing unit coverage includes API response decoding, non-success HTTP status handling, and decoding failures. See [API and app behavior](behavior/app.md) for coverage details and known verification limitations.
