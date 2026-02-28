import XCTest
@testable import Recording_App

final class UploaderTests: XCTestCase {

    var sut: Uploader!

    override func setUpWithError() throws {
        // Since it's a singleton, we test the shared instance.
        sut = Uploader.shared
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testUploadAudioSuccess200() {
        let testDestURL = URL(string: "http://testserver.com/upload")!
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let dummyFileURL = tempDir.appendingPathComponent("dummy_upload_success.wav")
        try? "dummy data".write(to: dummyFileURL, atomically: true, encoding: .utf8)
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)
        sut.session = mockSession
        
        let mockResponse = HTTPURLResponse(url: testDestURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        MockURLProtocol.requestHandler = { request in
            return (mockResponse, nil)
        }
        
        let expectation = self.expectation(description: "Upload Complete Success")
        sut.uploadAudio(fileURL: dummyFileURL, to: testDestURL) { result in
            if case .failure(let error) = result {
                XCTFail("Should not fail: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testUploadAudioFailure500() {
        let testDestURL = URL(string: "http://testserver.com/upload")!
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let dummyFileURL = tempDir.appendingPathComponent("dummy_upload_fail.wav")
        try? "dummy data".write(to: dummyFileURL, atomically: true, encoding: .utf8)
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)
        sut.session = mockSession
        
        let mockResponse = HTTPURLResponse(url: testDestURL, statusCode: 500, httpVersion: nil, headerFields: nil)!
        MockURLProtocol.requestHandler = { request in
            return (mockResponse, nil)
        }
        
        let expectation = self.expectation(description: "Upload Complete Failure")
        sut.uploadAudio(fileURL: dummyFileURL, to: testDestURL) { result in
            if case .success = result {
                XCTFail("Should not succeed on 500")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
