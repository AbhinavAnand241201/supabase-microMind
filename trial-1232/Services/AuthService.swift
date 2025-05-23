import Foundation

class AuthService {
    static let shared = AuthService()
    private let baseURL = "http://localhost:5000/api"
    
    private init() {}
    
    // Sign up a new user
    func signUp(email: String, password: String, name: String) async throws -> (user: User, token: String) {
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
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        guard httpResponse.statusCode == 201 else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw AuthError.serverError(errorResponse.message)
            }
            throw AuthError.invalidResponse
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        return (authResponse.user, authResponse.token)
    }
    
    // Log in an existing user
    func signIn(email: String, password: String) async throws -> (user: User, token: String) {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw AuthError.serverError(errorResponse.message)
            }
            throw AuthError.invalidResponse
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        return (authResponse.user, authResponse.token)
    }
    
    // Get current user
    func getCurrentUser(token: String) async throws -> User {
        let url = URL(string: "\(baseURL)/auth/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw AuthError.serverError(errorResponse.message)
            }
            throw AuthError.invalidResponse
        }
        
        let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
        return userResponse.user
    }
}

// Models
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

enum AuthError: Error {
    case invalidResponse
    case serverError(String)
} 