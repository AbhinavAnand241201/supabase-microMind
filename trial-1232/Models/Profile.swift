import Foundation

struct Profile: Identifiable, Codable {
    let id: String
    var email: String
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case updatedAt = "updated_at"
    }
} 