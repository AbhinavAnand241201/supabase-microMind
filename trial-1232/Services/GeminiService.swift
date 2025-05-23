import Foundation

enum GeminiError: Error {
    case invalidResponse
    case cannotParseResponse
}

class GeminiService {
    static let shared = GeminiService()
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    func analyzeJournal(content: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)?key=\(Constants.geminiAPIKey)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
You are a supportive counselor. Analyze the following journal entry (up to 200 words) and provide a 2-3 sentence insight about the user's emotional state or mood. Offer a gentle, empathetic suggestion for self-care or reflection, tailored to the entry's tone. Keep the response concise and uplifting.
Journal: \(content)
"""
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let candidates = json?["candidates"] as? [[String: Any]],
           let firstCandidate = candidates.first,
           let content = firstCandidate["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let text = parts.first?["text"] as? String {
            return text
        } else {
            throw GeminiError.cannotParseResponse
        }
    }
} 