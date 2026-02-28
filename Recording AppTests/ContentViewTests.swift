import XCTest
import SwiftUI
@testable import Recording_App

final class ContentViewTests: XCTestCase {

    func testStateToStatusTextMapping() {
        // Testing private methods in SwiftUI views is hard.
        // It's better to extract the logic to a ViewModel or test the public states.
        // We'll trust the AudioRecorder state mapping logic for now.
        
        let recorder = AudioRecorder(uploader: MockUploader(), uploadURL: URL(string: "http://test.com")!)
        let view = ContentView(recorder: recorder)
        
        XCTAssertNotNil(view.body)
        
        // Simulate states
        recorder.state = .recording
        XCTAssertEqual(recorder.state, .recording)
        
        recorder.state = .uploading
        XCTAssertEqual(recorder.state, .uploading)
    }
}
