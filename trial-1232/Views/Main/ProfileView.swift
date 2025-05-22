import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var newEmail = ""
    @State private var isEditing = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                        
                        Text("User Profile")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.top)
                    
                    // Profile Information
                    if let user = authViewModel.user {
                        VStack(alignment: .leading, spacing: 16) {
                            // User ID Section
                            VStack(alignment: .leading, spacing: 4) {
                                Text("User ID")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(user.id)
                                    .font(.subheadline)
                            }
                            
                            // Email Section
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Email")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                if isEditing {
                                    TextField("Email", text: $newEmail)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                } else {
                                    Text(user.email)
                                        .font(.subheadline)
                                }
                            }
                            
                            // Action Buttons
                            VStack(spacing: 12) {
                                Button(action: {
                                    if isEditing {
                                        Task {
                                            await authViewModel.updateEmail(newEmail: newEmail)
                                            isEditing = false
                                        }
                                    } else {
                                        isEditing = true
                                        newEmail = user.email
                                    }
                                }) {
                                    Text(isEditing ? "Save Changes" : "Edit Email")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                
                                Button(action: {
                                    Task {
                                        await authViewModel.signOut()
                                    }
                                }) {
                                    Text("Sign Out")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 2)
                    } else {
                        Text("No user data available")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Profile Update", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
} 