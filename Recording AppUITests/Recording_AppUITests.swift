import XCTest

final class Recording_AppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testPositiveUploadFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITest_MockServerSuccess"]
        app.launch()

        // Wait for idle state
        XCTAssertTrue(app.staticTexts["Idle"].waitForExistence(timeout: 2.0))

        // Tap Mic button
        let micButton = app.buttons.firstMatch
        micButton.tap()
        
        // Handle Microphone Permission Prompt if it appears
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowButton = springboard.buttons["OK"] // Or "Allow" depending on OS version
        if allowButton.waitForExistence(timeout: 2.0) {
            allowButton.tap()
            // If we just allowed it, `requestRecordPermission` callback happens asynchronously.
            // On first tap, it asks for permission. We may need to tap again if the app didn't automatically start.
            // But AudioRecorder.swift says:
            // if allowed { self?.startRecording() }
            // So it should start recording automatically.
        }

        // Verify "Recording..." state
        XCTAssertTrue(app.staticTexts["Recording..."].waitForExistence(timeout: 5.0))

        // Tap Stop button
        micButton.tap()

        // Verify "Uploading..." briefly
        // It might be too fast to catch with mocked local network, but we can try.
        // XCTAssertTrue(app.staticTexts["Uploading..."].waitForExistence(timeout: 1.0))
        
        // Verify "Upload successful"
        XCTAssertTrue(app.staticTexts["Upload successful"].waitForExistence(timeout: 5.0))
    }

    @MainActor
    func testNetworkFailureFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITest_MockServerFailure"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Idle"].waitForExistence(timeout: 2.0))

        let micButton = app.buttons.firstMatch
        micButton.tap()
        
        // Handle Microphone Permission
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowButton = springboard.buttons["OK"]
        if allowButton.waitForExistence(timeout: 2.0) {
            allowButton.tap()
        }

        XCTAssertTrue(app.staticTexts["Recording..."].waitForExistence(timeout: 5.0))

        // Tap Stop button
        micButton.tap()

        // Verify failure text
        let failedText = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH 'Upload failed'")).firstMatch
        XCTAssertTrue(failedText.waitForExistence(timeout: 5.0))
    }
    
    @MainActor
    func testMicrophonePermissionDenied() throws {
        // Reset permissions before testing
        let app = XCUIApplication()
        app.resetAuthorizationStatus(for: .microphone)
        app.launchArguments = ["-UITest_MockServerSuccess"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Idle"].waitForExistence(timeout: 2.0))

        let micButton = app.buttons.firstMatch
        micButton.tap()
        
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let dontAllowButton = springboard.buttons["Don’t Allow"]
        if dontAllowButton.waitForExistence(timeout: 2.0) {
            dontAllowButton.tap()
        }

        let failedText = app.staticTexts["Upload failed: Microphone Permission Denied"]
        XCTAssertTrue(failedText.waitForExistence(timeout: 5.0))
    }
}
