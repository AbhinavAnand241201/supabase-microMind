import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var user: User?
    @Published var showSignOutConfirmation = false
    
    @AppStorage("authToken") private var authToken: String?
    
    private let backend = BackendService.shared
    
    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil
        showSignOutConfirmation = false
        
        do {
            let response = try await backend.signUp(email: email, password: password, name: name)
            self.user = response.user
            self.authToken = response.token
            self.isAuthenticated = true
            self.errorMessage = nil
        } catch BackendError.serverError(let message) {
            self.errorMessage = message
        } catch BackendError.requestFailed(let error) {
             self.errorMessage = "Request failed: \(error.localizedDescription)"
        } catch {
            self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
         isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        showSignOutConfirmation = false

        do {
            let response = try await backend.signIn(email: email, password: password)
            self.user = response.user
            self.authToken = response.token
            self.isAuthenticated = true
            self.errorMessage = nil
        } catch BackendError.serverError(let message) {
            self.errorMessage = message
        } catch BackendError.requestFailed(let error) {
             self.errorMessage = "Request failed: \(error.localizedDescription)"
        } catch {
            self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func checkSession() async {
        guard let token = authToken else {
            self.isAuthenticated = false
            self.user = nil
            return
        }
        
        do {
            let response = try await backend.getCurrentUser(token: token)
            self.user = response.user
            self.isAuthenticated = true
            self.errorMessage = nil
        } catch {
            self.isAuthenticated = false
            self.user = nil
            self.authToken = nil
            self.errorMessage = "Session expired. Please log in again."
        }
    }
    
    func updateEmail(newEmail: String) async {
        guard let userId = user?.id, let token = authToken else {
            errorMessage = "User not logged in or token missing."
            return
        }
        isLoading = true
        errorMessage = nil
        showSignOutConfirmation = false
        
        do {
             let response = try await backend.updateUserEmail(userId: userId, newEmail: newEmail, token: token)
            self.user = response.user
            self.errorMessage = "Email updated successfully"
        } catch BackendError.serverError(let message) {
            self.errorMessage = message
        } catch BackendError.requestFailed(let error) {
             self.errorMessage = "Request failed: \(error.localizedDescription)"
        } catch {
            self.errorMessage = "Error updating email: \(error.localizedDescription)"
        }
         isLoading = false
    }
    
    func signOut() async {
        guard let token = authToken else {
            self.isAuthenticated = false
            self.user = nil
            self.authToken = nil
            self.errorMessage = nil
            showSignOutConfirmation = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        showSignOutConfirmation = false
        
        do {
             _ = try await backend.signOut(token: token)
            
            self.isAuthenticated = false
            self.user = nil
            self.authToken = nil
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Error signing out: \(error.localizedDescription)"
        }
         isLoading = false
    }
    
    @Published var isLoading = false
} 