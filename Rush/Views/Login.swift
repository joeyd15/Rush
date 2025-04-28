import SwiftUI

struct UserLoginView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("username") var storedUsername: String = ""
    @AppStorage("password") var storedPassword: String = ""
    @AppStorage("isAdmin") var isAdmin: Bool = false   // New property for admin privileges

    // Example credentials for testing purposes.
    let adminEmail = "admin@rushutk.com"
    let adminPassword = "password123"

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Big, bold, centered header.
                Text("Login to Rush UTK")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                // Email text field.
                TextField("Email", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Password secure field.
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Display an error message if there is one.
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // The Login button.
                Button(action: {
                    // Reset the error message.
                    errorMessage = nil
                    
                    // Check the entered credentials.
                    if username != adminEmail {
                        errorMessage = "Email not found"
                    } else if password != adminPassword {
                        errorMessage = "Password does not match"
                    } else {
                        // Credentials match; update AppStorage and set admin privileges.
                        storedUsername = username
                        storedPassword = password
                        isLoggedIn = true
                        isAdmin = true
                    }
                }, label: {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal)
                })
                
                Spacer()
            }
            .padding()
            // Hide the navigation bar so no title appears.
            .navigationBarHidden(true)
        }
    }
}

struct UserLoginView_Previews: PreviewProvider {
    static var previews: some View {
        UserLoginView()
    }
}

