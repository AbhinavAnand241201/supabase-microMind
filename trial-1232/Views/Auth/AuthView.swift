import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            LoginView()
                .tabItem {
                    Label("Login", systemImage: "person.fill")
                }
            
            SignupView()
                .tabItem {
                    Label("Sign Up", systemImage: "person.badge.plus")
                }
        }
        .onAppear {
            Task {
                await authViewModel.checkSession()
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AuthViewModel())
    }
} 