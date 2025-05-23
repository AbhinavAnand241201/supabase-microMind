import SwiftUI

struct JournalEntryView: View {
    let entry: JournalEntry
    let insight: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.content)
                .font(.body)
            
            if let insight = insight {
                Text("Insight: \(insight)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var homeViewModel = HomeViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Journal Your Thoughts")
                .font(.title)
                .fontWeight(.bold)
            
            TextEditor(text: $homeViewModel.journalText)
                .frame(height: 200)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                .onChange(of: homeViewModel.journalText) { _ in
                    homeViewModel.updateWordCount()
                }
            
            Text("Word Count: \(homeViewModel.wordCount)/200")
                .font(.caption)
            
            if homeViewModel.isLoading {
                ProgressView()
            }
            
            if let insight = homeViewModel.aiInsight {
                Text("Insight: \(insight)")
                    .font(.subheadline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            if let error = homeViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                
                if homeViewModel.showRetry {
                    Button(action: {
                        Task {
                            if let userId = authViewModel.user?.id {
                                await homeViewModel.submitJournal(userId: userId)
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
            
            Button(action: {
                Task {
                    if let userId = authViewModel.user?.id {
                        await homeViewModel.submitJournal(userId: userId)
                    }
                }
            }) {
                Text("Submit")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
    }
} 