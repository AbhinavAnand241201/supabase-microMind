import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var journalText = ""
    @Published var wordCount = 0
    @Published var aiInsight: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var journalEntries: [JournalEntry] = []
    
    private let supabase = SupabaseService.shared
    private let gemini = GeminiService.shared
    private let maxWords = 200
    private var subscriptionTask: Task<Void, Never>?
    
    init() {
        setupSubscription()
    }
    
    deinit {
        subscriptionTask?.cancel()
    }
    
    private func setupSubscription() {
        subscriptionTask = Task {
            do {
                if let userId = try await supabase.getCurrentSession()?.user.id {
                    let stream = try await supabase.subscribeToJournalEntries(userId: userId)
                    for await entry in stream {
                        if !journalEntries.contains(where: { $0.id == entry.id }) {
                            journalEntries.insert(entry, at: 0)
                        }
                    }
                }
            } catch {
                print("Error setting up subscription: \(error)")
            }
        }
    }
    
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
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Save to Supabase
            let entry = try await supabase.saveJournalEntry(content: journalText, userId: userId)
            journalEntries.insert(entry, at: 0)
            
            // Analyze with Gemini AI
            let insight = try await gemini.analyzeJournal(content: journalText)
            aiInsight = insight
            
            // Clear text after submission
            journalText = ""
            wordCount = 0
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadJournalEntries(userId: String) async {
        do {
            journalEntries = try await supabase.getJournalEntries(userId: userId)
        } catch {
            errorMessage = "Failed to load journal entries: \(error.localizedDescription)"
        }
    }
} 