import Foundation
import AVFoundation
import Combine
import SwiftUI

enum RecordState {
    case idle
    case recording
    case uploading
    case success
    case failure(String)
}

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var state: RecordState = .idle
    private var audioRecorder: AVAudioRecorder?
    private var recordedFileURL: URL?
    
    // Configurable endpoint
    let uploadURL = URL(string: "http://YOUR_MAC_LOCAL_IP:3000/upload")!
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            DispatchQueue.main.async {
                self.state = .failure("Session Setup Failed")
            }
        }
    }
    
    func requestPermissionAndStart() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self?.startRecording()
                } else {
                    self?.state = .failure("Microphone Permission Denied")
                }
            }
        }
    }
    
    private func startRecording() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let timestamp = formatter.string(from: Date())
        let fileName = "\(timestamp).wav"
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent(fileName)
        self.recordedFileURL = fileURL
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            state = .recording
        } catch {
            state = .failure("Failed to start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        // Handled in delegate or immediately
        state = .uploading
        
        guard let fileURL = recordedFileURL else {
            state = .failure("No file to upload")
            return
        }
        
        Uploader.shared.uploadAudio(fileURL: fileURL, to: uploadURL) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.state = .success
                    // Delete file on success
                    try? FileManager.default.removeItem(at: fileURL)
                case .failure(let error):
                    self?.state = .failure("Upload failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            DispatchQueue.main.async {
                self.state = .failure("Recording interrupted")
            }
        }
    }
}
