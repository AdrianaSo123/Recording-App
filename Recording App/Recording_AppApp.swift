import SwiftUI

@main
struct Recording_AppApp: App {
    @StateObject private var recorder = AudioRecorder()
    
    init() {
        #if DEBUG
        if CommandLine.arguments.contains("-UITest_MockServerSuccess") {
            setupMockServer(success: true)
        } else if CommandLine.arguments.contains("-UITest_MockServerFailure") {
            setupMockServer(success: false)
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(recorder: recorder)
        }
    }
}

#if DEBUG
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool { return true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else { fatalError() }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data { client?.urlProtocol(self, didLoad: data) }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    override func stopLoading() {}
}

func setupMockServer(success: Bool) {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    Uploader.shared.session = URLSession(configuration: config)

    MockURLProtocol.requestHandler = { request in
        let statusCode = success ? 200 : 500
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        return (response, nil)
    }
}
#endif
