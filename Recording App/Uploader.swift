import Foundation

class Uploader {
    static let shared = Uploader()
    
    private init() {}
    
    func uploadAudio(fileURL: URL, to destURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: destURL)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let filename = fileURL.lastPathComponent
        let mimeType = "audio/wav"
        let paramName = "audio"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        
        do {
            let audioData = try Data(contentsOf: fileURL)
            body.append(audioData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(()))
                } else {
                    let err = NSError(domain: "UploaderError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned \(httpResponse.statusCode)"])
                    completion(.failure(err))
                }
            } else {
                let err = NSError(domain: "UploaderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(err))
            }
        }
        task.resume()
    }
}
