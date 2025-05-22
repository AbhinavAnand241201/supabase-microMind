import Foundation
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var user: User?
    
    private let supabase = SupabaseService.shared
    
    func signUp(email: String, password: String) async {
        do {
            let response = try await supabase.signUp(email: email, password: password)
            if let user = response.user {
                self.user = User(id: user.id, email: user.email ?? "")
                self.isAuthenticated = true
                self.errorMessage = nil
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signIn(email: String, password: String) async {
        do {
            let response = try await supabase.signIn(email: email, password: password)
            if let user = response.user {
                self.user = User(id: user.id, email: user.email ?? "")
                self.isAuthenticated = true
                self.errorMessage = nil
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func checkSession() async {
        do {
            if let session = try await supabase.getCurrentSession() {
                self.user = User(id: session.user.id, email: session.user.email ?? "")
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
                self.user = nil
            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.isAuthenticated = false
        }
    }
    
    func updateEmail(newEmail: String) async {
        guard let userId = user?.id else {
            errorMessage = "No user logged in"
            return
        }
        
        // Validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: newEmail) else {
            errorMessage = "Invalid email format"
            return
        }
        
        do {
            let updatedUser = try await supabase.updateUserEmail(userId: userId, newEmail: newEmail)
            self.user = updatedUser
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signOut() async {
        do {
            try await supabase.signOut()
            self.isAuthenticated = false
            self.user = nil
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
} 