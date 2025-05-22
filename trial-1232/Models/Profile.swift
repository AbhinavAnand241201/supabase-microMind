import Foundation

struct Profile: Codable {
    let id: String
    let username: String?
    let fullName: String?
    let website: String?
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case website
        case avatarURL = "avatar_url"
    }
} 