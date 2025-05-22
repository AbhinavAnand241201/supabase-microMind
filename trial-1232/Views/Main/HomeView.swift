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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Journal Entry Section
                    VStack(spacing: 16) {
                        Text("Journal Your Thoughts")
                            .font(.title2)
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
                        
                        if let error = homeViewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
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
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 2)
                    
                    // Past Entries Section
                    if !homeViewModel.journalEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Past Entries")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(homeViewModel.journalEntries) { entry in
                                JournalEntryView(entry: entry, insight: homeViewModel.aiInsight)
                            }
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle")
                                .imageScale(.large)
                        }
                        Button("Past Chats") {
                            // Placeholder for Part 4
                        }
                    }
                }
            }
            .onAppear {
                if let userId = authViewModel.user?.id {
                    Task {
                        await homeViewModel.loadJournalEntries(userId: userId)
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
    }
} 