//
//  ContentView.swift
//  Recording App
//
//  Created by Adriana So on 2/25/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var recorder: AudioRecorder
    
    init(recorder: AudioRecorder = AudioRecorder()) {
        self._recorder = StateObject(wrappedValue: recorder)
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Button(action: {
                if recorder.state == .recording {
                    recorder.stopRecording()
                } else {
                    recorder.requestPermissionAndStart()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(recorder.state == .recording ? Color.red : Color.blue)
                        .frame(width: 120, height: 120)
                    
                    if recorder.state == .recording {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(statusText(for: recorder.state))
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
    
    private func statusText(for state: RecordState) -> String {
        switch state {
        case .idle: return "Idle"
        case .recording: return "Recording..."
        case .uploading: return "Uploading..."
        case .success: return "Upload successful"
        case .failure(let errorMsg): return "Upload failed: \(errorMsg)"
        }
    }
}

extension RecordState: Equatable {
    static func == (lhs: RecordState, rhs: RecordState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.recording, .recording), (.uploading, .uploading), (.success, .success):
            return true
        case (.failure(let a), .failure(let b)):
            return a == b
        default:
            return false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
