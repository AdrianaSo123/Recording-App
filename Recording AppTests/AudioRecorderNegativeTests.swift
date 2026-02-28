import XCTest
import AVFoundation
@testable import Recording_App

final class AudioRecorderNegativeTests: XCTestCase {

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

    func testInterruptedRecordingFailsGracefully() {
        // Direct testing of requestRecordPermission implies mocking AVAudioSession
        // Since AVAudioSession is a static singleton managed by the OS, it's very hard
        // to unit test permission requests without protocol abstractions around AVAudioSession.
        // We will test the audioRecorderDidFinishRecording delegate instead.
        
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let dummyFileURL = tempDir.appendingPathComponent("dummy_interrupt.wav")
        try? "dummy data".write(to: dummyFileURL, atomically: true, encoding: .utf8)
        
        // Settings are required for AVAudioRecorder init
        let settings: [String: Any] = [AVFormatIDKey: Int(kAudioFormatLinearPCM)]
        let recorder = try! AVAudioRecorder(url: dummyFileURL, settings: settings)
        
        // Simulate an interruption where flag is false
        sut.audioRecorderDidFinishRecording(recorder, successfully: false)
        
        let exp = expectation(description: "Interruption State")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if case .failure(let msg) = self.sut.state {
                XCTAssertEqual(msg, "Recording interrupted")
                exp.fulfill()
            } else {
                XCTFail("State should be failure(Recording interrupted)")
            }
        }
        waitForExpectations(timeout: 1.0)
    }
}
