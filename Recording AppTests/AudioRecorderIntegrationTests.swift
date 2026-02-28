import XCTest
@testable import Recording_App

final class AudioRecorderIntegrationTests: XCTestCase {

    var sut: AudioRecorder!
    var mockUploader: MockUploader!
    let testUploadURL = URL(string: "http://test.com/upload")!

    override func setUpWithError() throws {
        mockUploader = MockUploader()
        sut = AudioRecorder(uploader: mockUploader, uploadURL: testUploadURL)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockUploader = nil
    }

    func testStopRecordingTriggersUpload() {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let dummyFileURL = tempDir.appendingPathComponent("test_recording.wav")
        try? "dummy data".write(to: dummyFileURL, atomically: true, encoding: .utf8)
        
        sut.recordedFileURL = dummyFileURL
        
        // Mock a successful upload
        mockUploader.shouldSucceed = true
        
        // Trigger stop, which triggers upload
        sut.stopRecording()
        
        // Let async UI dispatch finish
        let exp = expectation(description: "Upload Success State")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.state, .success)
            // Verify file is deleted on success
            XCTAssertFalse(fileManager.fileExists(atPath: dummyFileURL.path))
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testFailedUploadKeepsLocalFile() {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let dummyFileURL = tempDir.appendingPathComponent("test_failure_recording.wav")
        try? "dummy data".write(to: dummyFileURL, atomically: true, encoding: .utf8)
        
        sut.recordedFileURL = dummyFileURL
        
        // Mock a failed upload
        mockUploader.shouldSucceed = false
        mockUploader.mockError = NSError(domain: "Test", code: 500, userInfo: nil)
        
        sut.stopRecording()
        
        let exp = expectation(description: "Upload Failure State")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if case .failure(_) = self.sut.state {
                // Assert it's a failure
            } else {
                XCTFail("State should be failure")
            }
            // Verify file still exists on failure
            XCTAssertTrue(fileManager.fileExists(atPath: dummyFileURL.path))
            // Cleanup
            try? fileManager.removeItem(at: dummyFileURL)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
}
