# Backlog

## Planned

- [x] **P1 — Add quiz behavior regression tests.** Cover empty categories, distinct answer choices, incorrect-answer retries, and completion in both quiz directions. Keep the current behavior stable before consolidating the view models.
- [x] **P1 — Share quiz flow between quiz directions.** Extract the common card sequence, answer validation, score, and completion logic from `CardsQuizViewModel` and `CardsQuizInvertViewModel`; leave only question/answer selection specific to each direction.
- [x] **P2 — Share word-pair parsing between the app and import extension.** Move the delimiter and trimming rules into one implementation used by both targets, then cover supported separators, empty fields, and values containing additional separators.
- [x] **P3 — Remove unused view-model state.** Drop stored `AppIntent` and `CategoryModel` references where they are only used during initialization and do not affect later behavior.
- [ ] **P3 — Review app coordination boundaries.** Assess whether `AppIntent` should delegate import handling and data refresh orchestration to narrower components; split only where it clarifies ownership and can be covered by focused tests.
