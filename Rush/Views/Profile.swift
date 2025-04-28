import SwiftUI

struct ProfileView: View {
    @AppStorage("username") var username: String = "user123"
    @AppStorage("password") var password: String = ""
    @State private var email: String = "user@example.com"
    @State private var notificationsEnabled: Bool = true
    @AppStorage("isDarkMode") private var darkMode: Bool = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    @AppStorage("institutionSelected") var institutionSelected: Bool = true
    @State private var balance: Double = 0.00  // Represents dues/fines balance

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Info")) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text("Username: \(username)")
                                .font(.headline)
                            Text("Password: \(password)")
                                .font(.subheadline)
                        }
                    }
                    Text("Email: \(email)")
                        .font(.subheadline)
                    Text("Balance: $\(String(format: "%.2f", balance))")
                        .font(.subheadline)
                        .foregroundColor(balance < 0 ? .red : .green)
                }
                Section(header: Text("Settings")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Dark Mode", isOn: $darkMode)
                }
                Section {
                    NavigationLink("Edit Profile", destination: EditProfileView(username: $username, email: $email, balance: $balance))
                }
                Section {
                    Button("Logout") {
                        // Reset login and institution selection.
                        isLoggedIn = false
                        institutionSelected = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct EditProfileView: View {
    @Binding var username: String
    @Binding var email: String
    @Binding var balance: Double
    
    var body: some View {
        Form {
            Section(header: Text("Edit Info")) {
                TextField("Username", text: $username)
                TextField("Email", text: $email)
            }
            Section(header: Text("Balance")) {
                TextField("Balance", value: $balance, format: .number)
                    .keyboardType(.decimalPad)
            }
        }
        .navigationTitle("Edit Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
