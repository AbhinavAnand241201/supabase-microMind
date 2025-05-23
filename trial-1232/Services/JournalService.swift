import Foundation

class JournalService {
    static let shared = JournalService()
    private let baseURL = "http://localhost:5000/api"
    
    private init() {}
    
    // Save a new journal entry
    func saveEntry(content: String, userId: String, token: String) async throws -> JournalEntry {
        let url = URL(string: "\(baseURL)/journal")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = [
            "content": content,
            "userId": userId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw JournalError.invalidResponse
        }
        
        guard httpResponse.statusCode == 201 else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw JournalError.serverError(errorResponse.message)
            }
            throw JournalError.invalidResponse
        }
        
        return try JSONDecoder().decode(JournalEntry.self, from: data)
    }
    
    // Get all journal entries for a user
    func getEntries(userId: String, token: String) async throws -> [JournalEntry] {
        let url = URL(string: "\(baseURL)/journal?userId=\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw JournalError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw JournalError.serverError(errorResponse.message)
            }
            throw JournalError.invalidResponse
        }
        
        return try JSONDecoder().decode([JournalEntry].self, from: data)
    }
}

struct JournalEntry: Codable, Identifiable {
    let id: String
    let content: String
    let userId: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content
        case userId
        case createdAt
    }
}

enum JournalError: Error {
    case invalidResponse
    case serverError(String)
} 