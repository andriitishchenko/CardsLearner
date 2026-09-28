# App behavior

## BUG-APP-009: Import each Share extension request only once
- Type: Bug
- Status: Resolved
- Scope: Text imports handed off from the iOS Share extension to the main app.
- Observed behavior / Reproduction: Share text to the app and confirm the import; the same word set can appear more than once because both the custom URL handler and app-activation handler process the App Group file.
- Goal / Acceptance criteria: A single Share extension request creates exactly one imported word set, even when URL delivery and scene activation both trigger handoff processing.
- Expected behavior and invariants: The extension's App Group import path is consumed once. A custom `lrnwcards://` URL without an `importFile` payload only wakes the app and must not read the pending shared file independently.
- Enforcement boundary: `AppIntent.handleImport`, `LearnerApp` URL and scene-phase handlers, and one-time App Group request consumption.
- Current behavior: A bare `lrnwcards://` URL only consumes the pending App Group request. The request path is removed before import handling, so a second URL/activation callback finds no work. Direct file URLs and URLs carrying an `importFile` parameter continue through the direct import handler. Failed file reads no longer fall back to stale App Group contents.
- Regression coverage: `LearnerTests.testSharedImportRequestIsConsumedOnlyOnce` verifies that a pending request URL is returned once and removed.
- Known limitations: The extension-to-app lifecycle is not exercised by an end-to-end UI test.

## BUG-APP-008: Show the text import action icon in the iOS share sheet
- Type: Bug
- Status: Resolved
- Scope: The iOS Share/action extension entry shown for supported text content.
- Observed behavior / Reproduction: Open the phone's Share menu for text that the extension accepts; its Import to Learn with Cards action has no icon.
- Goal / Acceptance criteria: The iOS action sheet displays an import-related icon beside the extension action.
- Expected behavior and invariants: The action icon is declared in the extension bundle's primary icon metadata and uses an iOS system symbol available at the extension's minimum deployment target.
- Enforcement boundary: `LearnerImport/Info.plist` and the `LearnerImport` extension bundle.
- Current behavior: The extension's primary icon metadata declares the `text.badge.plus` system symbol for the iOS action sheet. Finder and Touch Bar icon metadata remain configured separately.
- Regression coverage: No XCTest seam checks the system-rendered extension action sheet.
- Known limitations: The action sheet presentation depends on iOS and is not UI-tested in the project.

## BUG-APP-007: Restore delete and previous-card actions
- Type: Bug
- Status: Resolved
- Scope: Saved imported sets and card navigation in viewer, quiz, inverted quiz, and mixed-letters study modes.
- Observed behavior / Reproduction: The imported sets list has no way to delete a saved entry. Study modes do not consistently allow swiping back to the previous card or word.
- Goal / Acceptance criteria: Users can delete a saved imported set from its list and swipe right to revisit the previous card or word in each study mode. Swiping left continues to advance where currently supported.
- Expected behavior and invariants: Deletion updates both the visible list and persistent storage. Previous-card navigation stops at the first card and restores its study content; timed advancement must not override a newer navigation action.
- Enforcement boundary: `ImportedWordSetStore`, `ImportedSetsScreen`, study view models and their SwiftUI screens, and the `LearnerTests` XCTest target.
- Current behavior: The imported sets list supports swipe-to-delete and persists each deletion. Viewer, quiz, inverted quiz, and mixed-letters modes support horizontal swipes in both directions. Returning to an earlier card resets its current answer/input; pending timed advancement is cancelled.
- Regression coverage: `LearnerTests.testImportedWordSetCanBeDeleted` checks persisted deletion. `LearnerTests.testViewerCanReturnToThePreviousCardAndRecoverFromCompletion`, `LearnerTests.testQuizCanReturnToThePreviousCard`, and `LearnerTests.testMixedLettersCanReturnToThePreviousWord` cover previous-item navigation and boundaries.
- Known limitations: XCTest covers the view-model and storage behavior; rendered swipe recognition and the row's swipe-to-delete gesture are not UI-tested.

## BUG-APP-006: Return imported study sessions to the imported sets list
- Type: Bug
- Status: Resolved
- Scope: Returning from study options and card activities opened from a saved imported word set.
- Observed behavior / Reproduction: Select an imported word set, open a study mode, then use the Categories return action. It returns to the main categories list instead of the imported sets list.
- Goal / Acceptance criteria: Study activities opened from an imported set return to Imported words. Activities opened from a main-list category continue to return to Categories.
- Expected behavior and invariants: The return destination follows the source used to open the category, through the study-option and activity screens.
- Enforcement boundary: `AppIntent` route selection and the legacy navigation return action.
- Current behavior: Selecting a main-list category records Categories as the study return destination. Selecting a saved imported set records Imported words. The return action clears the activity route to that recorded destination and labels the return button accordingly; from the imported sets list, the same action returns to Categories.
- Regression coverage: `LearnerTests.testStudyReturnDestinationPreservesTheCategorySource` verifies the destination screen and title for both entry points.
- Known limitations: The test checks route destination state; rendered return navigation is not covered on device.

## BUG-APP-005: Open Settings and Imported words from the category screen
- Type: Bug
- Status: Resolved
- Scope: Settings and Imported words actions on the category screen, including compact-width navigation and initial local-data loading.
- Observed behavior / Reproduction: On a compact-width device, tapping either action can leave the categories column visible. Initial loading also forced a `.list` route after restoring local categories.
- Goal / Acceptance criteria: Tapping Settings opens the language settings screen; tapping Imported words opens the saved-import list.
- Expected behavior and invariants: Initial data loading must not replace a screen selected by the user. Compact-width devices use single-column navigation so Settings and Imported words replace the category screen; regular-width devices retain the split view.
- Enforcement boundary: `AppIntent.forceFetching`, size-class selection in `MainView`, both navigation containers, and `LearnerUITests`.
- Current behavior: Initial loading restores categories without adding a navigation route. `MainView` uses the single-column container on compact widths and the split-view container on regular widths. Both actions update the selected screen and route state.
- Regression coverage: `LearnerUITests.testScreenshots` checks Settings, returns to categories, opens Imported words, and checks its navigation bar.
- Known limitations: The UI test covers compact-width navigation on an iOS Simulator; it does not exercise the regular-width split view or iOS 15 runtime.

## FEAT-QUIZ-001: Preserve quiz behavior in both answer directions
- Type: Feature
- Status: Current
- Scope: Forward and reverse quiz view models.
- Goal / Acceptance criteria: Both quiz directions handle empty categories, build distinct choices containing the correct answer, allow another choice after an incorrect answer, count failed attempts, and finish after the final card.
- Expected behavior and invariants: Empty quizzes complete with a zero score and `0 of 0` progress. A presented question uses the card title in the forward quiz and its translation in the reverse quiz. Choices contain the correct answer and up to two distinct incorrect answers. Invalid selections are ignored; a valid incorrect answer records a failure and allows retry. A correct answer advances after the existing delay; swiping right revisits the previous question and swiping left advances; finishing reports the number of failed attempts.
- Enforcement boundary: `CardsQuizViewModel`, `CardsQuizInvertViewModel`, and the `LearnerTests` XCTest target.
- Current behavior: `CardsQuizViewModelBase` owns the shared sequence, choice generation, answer validation, scoring, completion, and previous/next navigation behavior. The forward and reverse view models provide the question and answer fields. Empty categories are handled, invalid selections are ignored, incorrect answers can be retried, a correct answer advances after a two-second delay, and horizontal swipes navigate between questions.
- Regression coverage: `LearnerTests.testForwardQuizBehavior` and `LearnerTests.testReverseQuizBehavior` cover empty categories, question direction, distinct choices containing the correct answer, ignored invalid selections, incorrect-answer retries, delayed advancement, and final scores. `LearnerTests.testQuizCanReturnToThePreviousCard` covers backward navigation and resetting the selected answer.
- Known limitations: The correct-answer advancement delay is fixed at two seconds, so the two flow tests wait for that delay.

## FEAT-IMPORT-001: Parse imported word pairs consistently
- Type: Feature
- Status: Current
- Scope: Text parsing in the main app and the import extension.
- Goal / Acceptance criteria: Both entry points apply the same delimiter precedence, trimming, empty-field rejection, and first-delimiter behavior.
- Expected behavior and invariants: Parse tab, semicolon, comma, spaced hyphen, en dash, em dash, and hyphen delimiters. Split once at the first matching delimiter, trim both values, preserve later delimiter text in the translation, and omit rows with an empty side or no delimiter.
- Enforcement boundary: Shared parser source included in the app and import extension, with coverage in the `LearnerTests` XCTest target.
- Current behavior: `WordPairParser` is compiled into the app and import extension; both entry points use its shared delimiter order and parsing rules.
- Regression coverage: `LearnerTests.testWordPairParserSupportsDelimitersAndPreservesLaterDelimiters` covers supported delimiters, trimming, and first-delimiter behavior. `LearnerTests.testWordPairParserRejectsMissingOrEmptyValues` covers malformed rows.
- Known limitations: Delimited input is parsed as simple word pairs; quoted CSV fields are not supported.

## FEAT-IMPORT-002: Persist and reopen imported word sets
- Type: Feature
- Status: Current
- Scope: Imported word sets in the main app, file and URL imports, pasted text, and the Share extension handoff.
- Goal / Acceptance criteria: Keep each successful import across app launches in a separate list. Show its import date and first word pair, open its cards through the existing study flow when selected, allow entries to be deleted, and offer file, URL, and pasted-text entry points from the list. Keep an always-visible main-menu entry and preserve Share imports.
- Expected behavior and invariants: Every successful import creates a distinct saved set with a timestamp and parsed word pairs. Invalid or empty imports are not saved. Selecting a saved set opens the existing category interaction screen with those pairs. Deleting a set removes it from the visible and persisted list. The main menu entry remains visible when the list is empty. The import list uses the app's existing system list styling.
- Enforcement boundary: `AppIntent`, imported-set persistence, `ImportedSetsScreen`, the category menu, and the `LearnerTests` XCTest target.
- Current behavior: Successful imports are saved as separate timestamped sets and survive app launches. The imports screen lists each date and first pair, supports deleting entries, and opens the existing study options when a set is selected. File, HTTP(S) URL, and pasted-text imports are available from that screen. The Share extension still hands off its file through the same app import handler.
- Regression coverage: `LearnerTests.testImportedWordSetsPersistAndKeepTheirWordPairs` verifies saving, reloading, ordering by import date, and retaining the first pair. `LearnerTests.testImportedWordSetCanBeDeleted` verifies deletion from persisted storage. The existing shared-parser tests cover the file, URL, and pasted-text parsing format.
- Known limitations: A set stores its parsed pairs and date locally with UserDefaults. The list does not support renaming sets.

## FEAT-APP-003: Build all Swift targets with Swift 6 safety
- Type: Feature
- Status: Current
- Scope: Main app, import extension, unit-test, and UI-test targets, including asynchronous UI state, imports, remote data loading, and Core Data access.
- Goal / Acceptance criteria: All project Swift targets compile in Swift 6 language mode and preserve the existing study, import, settings, and persistence flows.
- Expected behavior and invariants: UI state changes occur on the main actor; asynchronous work is awaited before dependent state changes; empty collections and malformed external data do not crash the app; persistence and network failures remain visible to callers.
- Enforcement boundary: `SWIFT_VERSION` settings in `Learner/Learner.xcodeproj/project.pbxproj`, Swift source files in `Learner/Learner/` and `Learner/LearnerImport/`, and the shared `Learner` scheme.
- Current behavior: App, import extension, unit-test, and UI-test targets use Swift 6 language mode. UI and Core Data access are main-actor isolated; remote values crossing concurrency boundaries are Sendable. Network image loading and reachability checks are asynchronous. Import parsing rejects empty pairs, retains text after the first delimiter, and avoids force-unwrapped settings or navigation state. Quiz options contain distinct choices and reject unavailable answers.
- Regression coverage: The `Learner` scheme's unit tests run on an iOS Simulator and cover API response handling, both quiz directions, and shared word-pair parsing. The project also builds the main app, import extension, unit-test target, and UI-test target in Swift 6 mode. Core Data queue use and broader screen-level behavior have no focused assertions.
- Known limitations: Build verification does not assess runtime behavior on physical devices or prove thread safety for code paths not exercised by the compiler. The app still relies on the configured remote repository data and app-group entitlements at runtime.

## BUG-APP-004: Support iOS 15 navigation and deployment
- Type: Bug
- Status: Current
- Scope: Main app and import extension deployment targets and the main app's root navigation.
- Observed behavior / Reproduction: Lowering the app deployment target below iOS 16 leaves the root view using `NavigationSplitView`, `NavigationStack`, and `NavigationSplitViewVisibility`, which are unavailable on iOS 15.
- Goal / Acceptance criteria: The app and import extension install on iOS 15.0 and later; category selection, settings, imports, and study screens work on iOS 15. The app uses platform-appropriate navigation containers without duplicating shared screen content.
- Expected behavior and invariants: iOS 15 and compact size classes use a single-column flow to show category selection and detail screens, with a return action to categories; iOS 16 and later use split navigation with a navigation stack in regular size classes. Category browsing, importing, and study-screen routing each have one shared implementation. Screen view models retain their state when unrelated `AppIntent` properties change. Async delays and other APIs used by the app remain available on iOS 15. All shipped targets use compatible deployment targets.
- Enforcement boundary: Xcode deployment settings, the availability router in `MainView`, platform navigation containers, shared navigation content views, `AppIntent` navigation state, and async delay call sites in view models.
- Current behavior: The app and import extension deployment targets are iOS 15.0. `MainView` selects a single-column `NavigationView` container on iOS 15 or in compact size classes, and a `NavigationSplitView` and `NavigationStack` container on iOS 16 and later in regular size classes. Shared category, import, and app-screen views are used by both containers. Route views own their view models as state objects, so unrelated `AppIntent` updates do not recreate screen state. `AppIntent` stores its navigation history as app-screen values, and view-model delays use the iOS 13-compatible nanosecond sleep API.
- Regression coverage: The generic iOS device build compiles the app and extension for arm64 with iOS 15.0 as their minimum OS. `LearnerUITests.testScreenshots` covers Settings and Imported words navigation in compact width. Quiz behavior and imports have focused unit coverage. No XCTest seam covers OS availability or route view-model retention; runtime navigation still needs an iOS 15 device for direct coverage.
- Known limitations: Unit-test and UI-test targets still require iOS 17.5, so they do not provide runtime coverage on iOS 15. The regular-width split view and route view-model lifetime have no focused automated coverage.

## BUG-APP-002: Link only required advertising package products
- Type: Bug
- Status: Resolved
- Scope: The main app's advertising package references and launch setup.
- Observed behavior / Reproduction: The app project linked Firebase products although no Firebase feature APIs were used. The Google User Messaging Platform package appeared in the lock files but was not declared as a project package or linked product.
- Goal / Acceptance criteria: The app target links Google Mobile Ads and Google User Messaging Platform, both with up-to-next-major version requirements. Unused Firebase references and initialization are removed while ad version logging, startup, banner sizing, loading, and delegate handling remain.
- Expected behavior and invariants: The app target has `GoogleMobileAds` and `GoogleUserMessagingPlatform` products from their Google package repositories. The project and resolved package graph contain no Firebase packages. Existing Google Mobile Ads presentation behavior remains available.
- Enforcement boundary: `Learner/Learner.xcodeproj/project.pbxproj`, the app launch setup in `Learner/Learner/LearnerApp.swift`, and both Xcode SwiftPM lock files.
- Current behavior: The app target links Google Mobile Ads 13.10.0 and Google User Messaging Platform 2.7.0 with up-to-next-major requirements. Both workspace lock files contain the same two resolved package pins. Firebase package references, products, initialization, and bundled service plist reference are removed.
- Regression coverage: `xcodebuild -resolvePackageDependencies` resolves the project and workspace package graphs. No targeted XCTest covers project package-product references or live ad loading.
- Known limitations: This record does not validate live ad requests or consent-form presentation at runtime.

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

The project also contains general and UI test targets. The unit-test target covers API responses, quiz behavior in both directions, and shared word-pair parsing. Keep test status claims limited to assertions present in the current tests.

The shared Xcode scheme includes the defined `LearnerUITests` target. The unit-test target covers API decoding and HTTP responses, quiz behavior in both directions, and the shared word-pair parser. Core Data queue use and broader screen-level behavior are not covered by focused assertions.
