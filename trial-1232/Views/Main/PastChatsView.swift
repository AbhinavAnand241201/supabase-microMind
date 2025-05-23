import SwiftUI

struct JournalEntryCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(entry.content)
                .font(.body)
                .lineLimit(3)
            
            if let insight = entry.aiInsight {
                Text("Insight: \(insight)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct PastChatsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var pastChatsViewModel = PastChatsViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Past Journal Entries")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    Task {
                        if let userId = authViewModel.user?.id {
                            await pastChatsViewModel.fetchEntries(userId: userId)
                        }
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            if pastChatsViewModel.isLoading {
                ProgressView()
            } else if pastChatsViewModel.journalEntries.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No journal entries yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Start journaling to see your entries here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(pastChatsViewModel.journalEntries) { entry in
                            JournalEntryCard(entry: entry)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            if let error = pastChatsViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
                
                if pastChatsViewModel.showRetry {
                    Button(action: {
                        Task {
                            if let userId = authViewModel.user?.id {
                                await pastChatsViewModel.fetchEntries(userId: userId)
                            }
                        }
                    }) {
                        Text("Retry")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .onAppear {
            Task {
                if let userId = authViewModel.user?.id {
                    await pastChatsViewModel.fetchEntries(userId: userId)
                }
            }
        }
    }
}

struct PastChatsView_Previews: PreviewProvider {
    static var previews: some View {
        PastChatsView()
            .environmentObject(AuthViewModel())
    }
} 