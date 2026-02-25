# Sprint 3: UI & Negative End-to-End (E2E) Testing
**Goal:** Test the app from the user's perspective (UI Tests) and aggressively test edge cases/failure modes.

- [ ] **Task 3.1:** E2E Negative Tests (Hardware/OS Level)
  - *Test:* **Permission Denied:** Simulate the user rejecting microphone access. Verify UI displays "Upload failed: Microphone Permission Denied" and stops.
  - *Test:* **Interrupted Recording:** Simulate an incoming phone call during recording. Verify the app handles the `audioRecorderDidFinishRecording` flag as `false` and resets state gracefully.
- [ ] **Task 3.2:** E2E Negative Tests (Network Level)
  - *Test:* **Server Unreachable:** Simulate the local Mac server being offline or airplane mode being active. Verify UI transitions from "Uploading..." to "Upload failed...".
  - *Test:* **Non-200 Responses:** Simulate `404 Not Found` or `413 Payload Too Large`. Verify UI handles the failure correctly.
- [ ] **Task 3.3:** Positive UI Flow
  - *Test:* Open App -> Verify "Idle" -> Tap Mic -> Verify "Recording..." -> Tap Stop -> Verify "Uploading..." -> Mock Success -> Verify "Upload successful".
