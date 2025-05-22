import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: Constants.supabaseURL)!,
    supabaseKey: Constants.supabaseKey
)

class SupabaseService {
    static let shared = SupabaseService()
    
    private init() {}
    
    // Sign up a new user
    func signUp(email: String, password: String) async throws -> AuthResponse {
        try await supabase.auth.signUp(email: email, password: password)
    }
    
    // Log in an existing user
    func signIn(email: String, password: String) async throws -> AuthResponse {
        try await supabase.auth.signIn(email: email, password: password)
    }
    
    // Get current user session
    func getCurrentSession() async throws -> Session? {
        try await supabase.auth.session
    }
    
    // Sign out
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    // Get user profile
    func getProfile(userId: String) async throws -> Profile {
        try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
    }
    
    // Update user profile
    func updateProfile(profile: Profile) async throws {
        try await supabase
            .from("profiles")
            .update(profile)
            .eq("id", value: profile.id)
            .execute()
    }
    
    // Upload avatar image
    func uploadAvatar(data: Data, path: String) async throws {
        try await supabase.storage
            .from("avatars")
            .upload(
                path,
                data: data,
                options: FileOptions(contentType: "image/jpeg")
            )
    }
    
    // Download avatar image
    func downloadAvatar(path: String) async throws -> Data {
        try await supabase.storage
            .from("avatars")
            .download(path: path)
    }
    
    // Save journal entry
    func saveJournalEntry(content: String, userId: String) async throws -> JournalEntry {
        let entry = JournalEntry(id: UUID(), userId: userId, content: content, createdAt: Date())
        try await supabase.database
            .from("journal_entries")
            .insert(values: entry)
            .execute()
        return entry
    }
    
    // Get user's journal entries
    func getJournalEntries(userId: String) async throws -> [JournalEntry] {
        try await supabase.database
            .from("journal_entries")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    // Subscribe to journal entries updates
    func subscribeToJournalEntries(userId: String) async throws -> AsyncStream<JournalEntry> {
        let channel = supabase.realtimeV2.channel("public:journal_entries")
        let insertions = channel.postgresChange(InsertAction.self, table: "journal_entries")
        
        await channel.subscribe()
        
        return AsyncStream { continuation in
            Task {
                for await insertion in insertions {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let entry = try insertion.decodeRecord(decoder: decoder) as JournalEntry
                        if entry.userId == userId {
                            continuation.yield(entry)
                        }
                    } catch {
                        print("Error decoding journal entry: \(error)")
                    }
                }
            }
        }
    }
} 