import Foundation

struct Profile: Codable {
    let id: String
    let email: String
    let name: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case name
        case createdAt
    }
} 