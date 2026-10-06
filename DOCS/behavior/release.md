# Release automation behavior

## BUG-RELEASE-001: Use automatic App Store signing during export
- Type: Bug
- Status: Resolved
- Scope: App Store exports produced by `bundle exec fastlane ios release`, including the main app and Share extension.
- Observed behavior / Reproduction: The archive succeeds, but export fails because the lane pins the app to a provisioning-profile UUID that is not installed, provides no profile mapping for the Share extension's App Groups entitlement, and Xcode reports no matching Apple Distribution certificate with a private key for the team.
- Goal / Acceptance criteria: Export with Xcode automatic signing so the app and extension can use current App Store provisioning profiles instead of a stale, hard-coded profile UUID.
- Expected behavior and invariants: The lane requests an App Store Connect export and allows Xcode to manage signing for both bundle identifiers. The existing App Groups entitlement remains part of the extension's signed profile. App Store upload starts only after export succeeds.
- Enforcement boundary: `fastlane/Fastfile`, Xcode automatic signing settings, target bundle identifiers and entitlements.
- Current behavior: The lane requests an `app-store-connect` export, enables Xcode provisioning updates for archive and export, and uses automatic signing without a pinned profile UUID. It delegates profile selection and updates to Xcode for the main app and Share extension using each target's configured bundle identifier and entitlements. The lane reaches App Store upload only after `gym` has produced the export.
- Regression coverage: No automated Fastlane lane test or XCTest seam covers export signing options.
- Known limitations: Export still depends on Xcode being signed in to the Apple Developer team, with automatic signing allowed for both bundle identifiers and the App Groups capability. The team must permit cloud-managed signing or provide an Apple Distribution certificate with its private key. The lane combines export with App Review submission and automatic release; it is not an export-only workflow.
