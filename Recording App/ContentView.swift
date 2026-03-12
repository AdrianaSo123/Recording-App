//
//  ContentView.swift
//  Recording App
//
//  Created by Adriana So on 2/25/26.
//

import SwiftUI

// MARK: - Design tokens matching So Studio aesthetic
private extension Color {
    static let studioBackground = Color(red: 0.918, green: 0.906, blue: 0.878) // warm off-white #EAE7E0
    static let studioNavy       = Color(red: 0.169, green: 0.176, blue: 0.431) // deep indigo   #2B2D6E
    static let studioNavyLight  = Color(red: 0.169, green: 0.176, blue: 0.431).opacity(0.55)
    static let studioAccent     = Color(red: 0.169, green: 0.176, blue: 0.431).opacity(0.18)
    static let studioRed        = Color(red: 0.72, green: 0.20, blue: 0.20)
}

struct ContentView: View {
    @ObservedObject var recorder: AudioRecorder

    // Pulsing animation for the recording ring
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Color.studioBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header ──────────────────────────────────────────────
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.studioNavy)
                        Text("So Studio")
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                            .foregroundColor(.studioNavy)
                    }
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 56)
                .padding(.bottom, 40)

                Spacer()

                // ── Decorative dots ──────────────────────────────────────
                HStack(spacing: 16) {
                    ForEach(0..<3) { _ in
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .thin))
                            .foregroundColor(.studioNavyLight)
                    }
                }
                .padding(.bottom, 24)

                // ── Title ────────────────────────────────────────────────
                Text("Recording Studio")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundColor(.studioNavy)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 14)

                Text("Capture your voice, explore your ideas.")
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundColor(.studioNavyLight)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)

                // ── Subtitle / status hint ───────────────────────────────
                Text(subtitleText(for: recorder.state))
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .italic()
                    .foregroundColor(.studioNavyLight)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
                    .animation(.easeInOut(duration: 0.3), value: recorder.state)

                // ── Mic button ───────────────────────────────────────────
                Button(action: {
                    if recorder.state == .recording {
                        recorder.stopRecording()
                        isPulsing = false
                    } else {
                        recorder.requestPermissionAndStart()
                        isPulsing = true
                    }
                }) {
                    ZStack {
                        // Outer pulsing ring (only while recording)
                        if recorder.state == .recording {
                            Circle()
                                .stroke(Color.studioRed.opacity(0.25), lineWidth: 2)
                                .frame(width: isPulsing ? 148 : 124, height: isPulsing ? 148 : 124)
                                .animation(
                                    .easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                                    value: isPulsing
                                )
                        }

                        // Button circle
                        Circle()
                            .strokeBorder(
                                recorder.state == .recording ? Color.studioRed : Color.studioNavy,
                                lineWidth: 1.5
                            )
                            .background(
                                Circle().fill(
                                    recorder.state == .recording
                                        ? Color.studioRed.opacity(0.08)
                                        : Color.studioAccent
                                )
                            )
                            .frame(width: 118, height: 118)

                        // Icon
                        if recorder.state == .recording {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.studioRed)
                                .frame(width: 28, height: 28)
                        } else if recorder.state == .uploading {
                            ProgressView()
                                .tint(.studioNavy)
                        } else {
                            Image(systemName: "mic")
                                .font(.system(size: 30, weight: .light))
                                .foregroundColor(.studioNavy)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(recorder.state == .uploading)
                .padding(.bottom, 40)

                // ── Action label ─────────────────────────────────────────
                Text(actionLabel(for: recorder.state))
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .tracking(1.5)
                    .foregroundColor(.studioNavy)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .overlay(
                        Capsule().stroke(Color.studioNavy, lineWidth: 1)
                    )
                    .animation(.easeInOut(duration: 0.3), value: recorder.state)

                Spacer()
                Spacer()
            }
        }
    }

    // Short italic subtitle beneath the headline
    private func subtitleText(for state: RecordState) -> String {
        switch state {
        case .idle:                    return "Tap the circle to begin a recording."
        case .recording:               return "Listening… tap again to stop."
        case .uploading:               return "Sending your recording…"
        case .success:                 return "Your recording was uploaded successfully."
        case .failure(let errorMsg):   return "Something went wrong: \(errorMsg)"
        }
    }

    // Pill button label
    private func actionLabel(for state: RecordState) -> String {
        switch state {
        case .idle:      return "START RECORDING"
        case .recording: return "STOP RECORDING"
        case .uploading: return "UPLOADING"
        case .success:   return "UPLOAD SUCCESSFUL"
        case .failure:   return "TRY AGAIN"
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
        ContentView(recorder: AudioRecorder())
    }
}
