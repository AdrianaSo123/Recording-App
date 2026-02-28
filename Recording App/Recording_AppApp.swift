//
//  Recording_AppApp.swift
//  Recording App
//
//  Created by Adriana So on 2/25/26.
//

import SwiftUI

@main
struct Recording_AppApp: App {
    @StateObject private var recorder = AudioRecorder()
    
    var body: some Scene {
        WindowGroup {
            ContentView(recorder: recorder)
        }
    }
}
