import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @AppStorage("password") var password: String = ""
    @AppStorage("isDarkMode") private var darkMode: Bool = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    @AppStorage("institutionSelected") var institutionSelected: Bool = true
    @State private var notificationsEnabled: Bool = true

    @State private var birthday: Date = Date()
    @State private var phoneNumber: String = ""
    @State private var profileImage: Image? = Image(systemName: "person.crop.circle")
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?

    @State private var saveStatus: String?

    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            Form {
                // Profile Picture (display only, no saving)
                Section(header: Text("Profile Picture")) {
                    HStack {
                        profileImage?
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .shadow(radius: 3)

                        Button("Change Photo") {
                            showImagePicker = true
                        }
                    }
                }

                // Editable Info
                Section(header: Text("Profile Info")) {
                    TextField("Username", text: $username)
                    Text("Email: \(email)")
                }

                Section(header: Text("Contact Info")) {
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                }

                Section(header: Text("Settings")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Dark Mode", isOn: $darkMode)
                }

                // Save button
                Section {
                    Button("Save Changes") {
                        saveProfileToFirestore()
                    }
                    .foregroundColor(.blue)

                    if let saveStatus = saveStatus {
                        Text(saveStatus)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                // Logout
                Section {
                    Button("Logout") {
                        isLoggedIn = false
                        institutionSelected = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                if let user = Auth.auth().currentUser {
                    self.email = user.email ?? "No email"
                    self.username = user.email?.components(separatedBy: "@").first ?? "Unknown"

                    let docRef = db.collection("users").document(user.uid)
                    docRef.getDocument { snapshot, error in
                        if let data = snapshot?.data() {
                            self.username = data["username"] as? String ?? self.username
                            self.phoneNumber = data["phone"] as? String ?? ""
                            self.birthday = (data["birthday"] as? Timestamp)?.dateValue() ?? Date()
                        }
                    }
                }
            }
            .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
        }
    }

    func saveProfileToFirestore() {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found.")
            return
        }

        let userDoc = db.collection("users").document(user.uid)
        userDoc.setData([
            "email": user.email ?? "",
            "username": username,
            "phone": phoneNumber,
            "birthday": Timestamp(date: birthday)
        ], merge: true) { error in
            if let error = error {
                print("❌ Firestore error: \(error.localizedDescription)")
                saveStatus = "Error: \(error.localizedDescription)"
            } else {
                print("✅ Profile updated successfully")
                saveStatus = "Profile updated!"
            }
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
    }
}
