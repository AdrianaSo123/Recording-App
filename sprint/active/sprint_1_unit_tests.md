# Sprint 1: Unit Testing Foundation
**Goal:** Ensure individual components handle state and formatting correctly in isolation.

- [ ] **Task 1.1:** Setup `AudioRecorderTests` unit test class.
  - *Test:* Verify initial state is `.idle`.
  - *Test:* Verify date formatting for file creation strictly follows `YYYY-MM-DD-HHMMSS.wav`.
  - *Test:* Verify state transitions (`.idle` -> `.recording` -> `.uploading`).
- [ ] **Task 1.2:** Setup `UploaderTests` unit test class.
  - *Test:* Verify `URLRequest` generation (correct HTTP method `POST`, correct URL).
  - *Test:* Verify `multipart/form-data` payload syntax (boundary generation, correct field name `audio`, correct MIME type).
- [ ] **Task 1.3:** Setup `ContentViewTests` (or ViewModel if we extract one).
  - *Test:* Verify `statusText` maps correctly to `RecordState`.
