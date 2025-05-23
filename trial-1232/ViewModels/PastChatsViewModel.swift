import Foundation
import SwiftUI // Import SwiftUI for @AppStorage

@MainActor
class PastChatsViewModel: ObservableObject {
    @Published var journalEntries: [JournalEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showRetry = false
    
    @AppStorage("authToken") private var authToken: String?
    
    private let backend = BackendService.shared
    
    func fetchEntries(userId: String) async {
        guard let token = authToken else {
            errorMessage = "Authentication token missing."
            return
        }
        
        isLoading = true
        errorMessage = nil
        showRetry = false
        
        do {
            let entries = try await backend.fetchJournalEntries(userId: userId, token: token)
            journalEntries = entries
        } catch BackendError.serverError(let message) {
            errorMessage = "Server error: \(message)"
            showRetry = true
        } catch BackendError.requestFailed(let error) {
             errorMessage = "Request failed: \(error.localizedDescription)"
             showRetry = true
        } catch {
            errorMessage = "Failed to load journal entries: \(error.localizedDescription)"
            showRetry = true
        }
        
        isLoading = false
    }
} 