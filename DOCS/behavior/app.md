# App behavior

## FEAT-APP-001: Declare non-exempt encryption usage

- Type: Feature
- Status: Current
- Scope: Main iOS app bundle metadata.
- Goal / Acceptance criteria: The main app's `Learner/Learner/Info.plist` contains `ITSAppUsesNonExemptEncryption` with the Boolean value `false`.
- Expected behavior and invariants: The built app's source property list retains this Boolean declaration; it must not be moved to the import extension's property list as a substitute.
- Enforcement boundary: `Learner/Learner/Info.plist`, selected as the main app target's `INFOPLIST_FILE` in `Learner/Learner.xcodeproj/project.pbxproj`.
- Current behavior: The property is present and set to false in the main app property list.
- Regression coverage: No automated plist assertion exists in the current XCTest targets. Verify the property list and target build setting when this metadata changes.
- Known limitations: This record tracks the requested property-list declaration; it does not independently assess the app's cryptographic implementation or export classification.

## API client behavior

`APIClientTests.swift` covers successful JSON decoding, rejection of non-2xx HTTP responses, and decoding failures. The client throws a bad-URL error for malformed endpoints, but the current unit tests do not cover that path. Add regression coverage when changing these behaviors.

The project also contains general and UI test targets. The general `LearnerTests.swift` file currently contains example and performance stubs without behavioral assertions. Keep test status claims limited to assertions present in the current tests.

The shared Xcode scheme lists a `LearnerUITests1` testable, but the project file defines `LearnerUITests` and has no `LearnerUITests1` target. This mismatch may prevent the documented scheme test command from running as configured; verify the scheme before relying on it for regression checks.
