# Sprint 2: Integration Testing
**Goal:** Ensure components work together properly, from microphone bridging to network layer abstraction.

- [ ] **Task 2.1:** AudioRecorder + Local Sandbox Integration
  - *Test:* Verify `stopRecording()` actually queues an upload to `Uploader.shared` with a valid file URL.
  - *Test:* Verify successful upload scenario triggers the deletion of the local `.wav` file.
  - *Test:* Verify failed upload scenario keeps the `.wav` file in the sandbox.
- [ ] **Task 2.2:** Uploader + Mock HTTP Server
  - *Test:* Use a custom `URLProtocol` to intercept `URLSession` traffic.
  - *Test:* Simulate a `200 OK` response and verify the completion handler returns `.success`.
  - *Test:* Simulate a `500 Internal Server Error` and verify the completion handler returns an appropriate `.failure`.
