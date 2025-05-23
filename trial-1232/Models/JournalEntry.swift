import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let userId: String
    let content: String
    let createdAt: Date
    let aiInsight: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case content
        case createdAt = "created_at"
        case aiInsight = "ai_insight"
    }
} 