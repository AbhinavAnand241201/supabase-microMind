import Foundation

enum BackendError: Error {
    case invalidResponse
    case serverError(String)
    case requestFailed(Error)
    case decodingError(Error)
}

class BackendService {
    static let shared = BackendService()
    
    private let baseURL = Constants.backendURL
    
    private init() {}
    
    private func performRequest<T: Decodable>(urlRequest: URLRequest) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BackendError.invalidResponse
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw BackendError.serverError(errorResponse.message)
                } else {
                    throw BackendError.invalidResponse
                }
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            if error is BackendError {
                throw error
            } else {
                throw BackendError.requestFailed(error)
            }
        }
    }
    
    // Sign up a new user
    func signUp(email: String, password: String, name: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "email": email,
            "password": password,
            "name": name
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        return try await performRequest(urlRequest: request)
    }
    
    // Log in an existing user
    func signIn(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        return try await performRequest(urlRequest: request)
    }
    
    // Get current user
    func getCurrentUser(token: String) async throws -> UserResponse {
        let url = URL(string: "\(baseURL)/auth/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await performRequest(urlRequest: request)
    }
    
    // Save a new journal entry
    func saveJournalEntry(content: String, userId: String, aiInsight: String?, token: String) async throws -> JournalEntry {
        let url = URL(string: "\(baseURL)/journal")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "content": content,
            "userId": userId,
            "aiInsight": aiInsight as Any
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        return try await performRequest(urlRequest: request)
    }
    
    // Get all journal entries for a user
    func fetchJournalEntries(userId: String, token: String) async throws -> [JournalEntry] {
        let url = URL(string: "\(baseURL)/journal?userId=\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let entries: [JournalEntry] = try await performRequest(urlRequest: request)
        return entries
    }
    
    // Update user email
    func updateUserEmail(userId: String, newEmail: String, token: String) async throws -> UserResponse {
         let url = URL(string: "\(baseURL)/users/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = [
            "email": newEmail
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        return try await performRequest(urlRequest: request)
    }
    
    // Sign out
    func signOut(token: String) async throws -> SuccessResponse {
        let url = URL(string: "\(baseURL)/auth/logout")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await performRequest(urlRequest: request)
    }
}

// Models (should match your backend response structures)
struct User: Codable {
    let id: String
    let email: String
    let name: String
}

struct AuthResponse: Codable {
    let user: User
    let token: String
}

struct UserResponse: Codable {
    let user: User
}

struct ErrorResponse: Codable {
    let message: String
}

struct SuccessResponse: Codable {
    let message: String
}

struct JournalEntry: Codable, Identifiable {
    let id: String
    let content: String
    let userId: String
    let createdAt: Date
    let aiInsight: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content
        case userId
        case createdAt
        case aiInsight
    }
} 