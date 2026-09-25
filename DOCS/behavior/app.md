# App behavior

## FEAT-APP-003: Build all Swift targets with Swift 6 safety
- Type: Feature
- Status: Current
- Scope: Main app, import extension, unit-test, and UI-test targets, including asynchronous UI state, imports, remote data loading, and Core Data access.
- Goal / Acceptance criteria: All project Swift targets compile in Swift 6 language mode and preserve the existing study, import, settings, and persistence flows.
- Expected behavior and invariants: UI state changes occur on the main actor; asynchronous work is awaited before dependent state changes; empty collections and malformed external data do not crash the app; persistence and network failures remain visible to callers.
- Enforcement boundary: `SWIFT_VERSION` settings in `Learner/Learner.xcodeproj/project.pbxproj`, Swift source files in `Learner/Learner/` and `Learner/LearnerImport/`, and the shared `Learner` scheme.
- Current behavior: App, import extension, unit-test, and UI-test targets use Swift 6 language mode. UI and Core Data access are main-actor isolated; remote values crossing concurrency boundaries are Sendable. Network image loading and reachability checks are asynchronous. Import parsing rejects empty pairs, retains text after the first delimiter, and avoids force-unwrapped settings or navigation state. Quiz choices avoid duplicate display identifiers and reject unavailable answers.
- Regression coverage: `xcodebuild build-for-testing` successfully compiles the main app, import extension, unit-test target, and UI-test target in Swift 6 mode; tests were not run. Existing XCTest assertions cover API decoding and HTTP status handling. There are no focused assertions for import parsing, Core Data queue use, or view-model edge cases.
- Known limitations: Build verification does not assess runtime behavior on physical devices or prove thread safety for code paths not exercised by the compiler. The app still relies on the configured remote repository data and app-group entitlements at runtime.

## BUG-APP-002: Link only available Firebase package products
- Type: Bug
- Status: Resolved
- Scope: The main app's Swift Package Manager product references and Google Mobile Ads API call sites.
- Observed behavior / Reproduction: Resolving current Firebase packages and building the `Learner` scheme fails when a Firebase package product referenced by the project is no longer published by the resolved SDK. The current Google Mobile Ads SDK rejects legacy Swift names used by the app's banner wrappers and adaptive banner sizing.
- Goal / Acceptance criteria: The app target links Firebase products that exist in the resolved SDK and uses current Google Mobile Ads APIs while preserving analytics without IDFA collection, version logging, ad startup, width-responsive banner sizing, loading, and delegate handling.
- Expected behavior and invariants: The project builds against its resolved Firebase and Google Mobile Ads SDKs without missing-product or renamed-API errors; Firebase analytics continues without IDFA collection, Firebase initialization works, and ad presentation remains available.
- Enforcement boundary: `Learner/Learner.xcodeproj/project.pbxproj` package product dependencies and the Google Mobile Ads call sites in `Learner/Learner/Presentation/Views/`.
- Current behavior: The project links `FirebaseAnalyticsCore`, App Check, and App Distribution Beta from Firebase 12.19.2. Analytics uses the current Firebase product without IDFA collection. The app initializes Google Mobile Ads 13.10.0 and displays adaptive banners using the current SDK's Swift API names. The resolved package graph builds for the generic iOS Simulator destination.
- Regression coverage: The documented Xcode build verifies package product resolution and app compilation. No targeted XCTest covers project package-product references or live ad loading.
- Known limitations: The app imports Firebase Core directly and does not call Firebase Analytics APIs in source; this record does not validate server-side Firebase configuration or runtime ad requests.

## FEAT-APP-001: Declare non-exempt encryption usage

- Type: Feature
- Status: Current
- Scope: Main iOS app bundle metadata.
- Goal / Acceptance criteria: The built main app contains `ITSAppUsesNonExemptEncryption` with the Boolean value `false`.
- Expected behavior and invariants: The generated app bundle retains this Boolean declaration; the import extension's property list does not substitute for the main app's metadata.
- Enforcement boundary: `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the main app target's Debug and Release build settings in `Learner/Learner.xcodeproj/project.pbxproj`.
- Current behavior: Xcode generates the main app bundle property from the target build setting; the source `Learner/Learner/Info.plist` does not declare the key.
- Regression coverage: No automated plist assertion exists in the current XCTest targets. Verify the generated app metadata and target build settings when this metadata changes.
- Known limitations: This record tracks the requested property-list declaration; it does not independently assess the app's cryptographic implementation or export classification.

## API client behavior

`APIClientTests.swift` covers successful JSON decoding, rejection of non-2xx HTTP responses, and decoding failures. The client throws a bad-URL error for malformed endpoints, but the current unit tests do not cover that path. Add regression coverage when changing these behaviors.

The project also contains general and UI test targets. The general `LearnerTests.swift` file currently contains example and performance stubs without behavioral assertions. Keep test status claims limited to assertions present in the current tests.

The shared Xcode scheme includes the defined `LearnerUITests` target. The unit-test target has assertions for API decoding, non-success HTTP responses, and decoding errors; broader import, persistence, and view-model behavior is not covered by focused assertions.
