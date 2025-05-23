import Foundation
import SwiftUI // Import SwiftUI for @AppStorage

@MainActor
class HomeViewModel: ObservableObject {
    @Published var journalText = ""
    @Published var wordCount = 0
    @Published var aiInsight: String? // Keep aiInsight for immediate display
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showRetry = false
    @Published var journalEntries: [JournalEntry] = [] // Add journalEntries here for displaying past entries in HomeView
    
    @AppStorage("authToken") private var authToken: String?
    
    private let backend = BackendService.shared
    private let gemini = GeminiService.shared
    private let maxWords = 200
    
    func updateWordCount() {
        let words = journalText.split { $0.isWhitespace || $0.isNewline }
        wordCount = min(words.count, maxWords)
        if wordCount > maxWords {
            journalText = words.prefix(maxWords).joined(separator: " ")
        }
    }
    
    func submitJournal(userId: String) async {
        guard !journalText.isEmpty else {
            errorMessage = "Journal entry cannot be empty"
            return
        }
        
        guard let token = authToken else {
             errorMessage = "Authentication token missing."
             return
        }
        
        isLoading = true
        errorMessage = nil
        showRetry = false
        aiInsight = nil // Clear previous insight
        
        do {
            // Analyze with Gemini AI first
            let insight = try await gemini.analyzeJournal(content: journalText)
            aiInsight = insight // Display immediately after analysis
            
            // Save to backend with the insight
            let entry = try await backend.saveJournalEntry(content: journalText, userId: userId, aiInsight: insight, token: token)
            // Optionally add the new entry to the journalEntries array if you want to display it immediately in the list
             journalEntries.insert(entry, at: 0)
            
            // Clear text after submission
            journalText = ""
            wordCount = 0
        } catch BackendError.serverError(let message) {
            errorMessage = "Server error: \(message)"
            showRetry = true
        } catch BackendError.requestFailed(let error) {
             errorMessage = "Request failed: \(error.localizedDescription)"
             showRetry = true
        } catch GeminiError.cannotParseResponse {
            errorMessage = "Failed to get AI insight: Cannot parse response."
            showRetry = true
        } catch {
            errorMessage = "Failed to save entry: \(error.localizedDescription)"
            showRetry = true
        }
        
        isLoading = false
    }
    
    func loadJournalEntries(userId: String) async {
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
        }  catch BackendError.requestFailed(let error) {
             errorMessage = "Request failed: \(error.localizedDescription)"
             showRetry = true
        } catch {
            errorMessage = "Failed to load journal entries: \(error.localizedDescription)"
            showRetry = true
        }
        
        isLoading = false
    }
} 