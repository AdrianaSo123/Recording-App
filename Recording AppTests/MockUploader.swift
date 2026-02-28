import Foundation
@testable import Recording_App

class MockUploader: AudioUploading {
    var shouldSucceed = true
    var uploadCalled = false
    var lastUploadedFileURL: URL?
    var lastDestURL: URL?
    var mockError: Error = NSError(domain: "MockError", code: 1, userInfo: nil)
    
    func uploadAudio(fileURL: URL, to destURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        uploadCalled = true
        lastUploadedFileURL = fileURL
        lastDestURL = destURL
        
        if shouldSucceed {
            completion(.success(()))
        } else {
            completion(.failure(mockError))
        }
    }
}
