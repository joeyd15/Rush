import SwiftUI
import FirebaseAuth

struct UserLoginView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("isAdmin") var isAdmin: Bool = false

    @State private var isLoginMode = true
    @State private var isResetMode = false

    @State private var email: String = ""
    @State private var password: String = ""

    @State private var errorMessage: String? = nil
    @State private var infoMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Text(viewTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if !isResetMode {
                    Picker(selection: $isLoginMode, label: Text("Mode")) {
                        Text("Log In").tag(true)
                        Text("Sign Up").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }

                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                if !isResetMode {
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }

                if let error = errorMessage {
                    Text(error).foregroundColor(.red).padding(.horizontal)
                }

                if let info = infoMessage {
                    Text(info).foregroundColor(.blue).padding(.horizontal)
                }

                Button(action: {
                    isResetMode ? sendResetPassword() : handleAuth()
                }) {
                    Text(isResetMode ? "Send Reset Email" : (isLoginMode ? "Log In" : "Create Account"))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isResetMode ? Color.orange : (isLoginMode ? Color.blue : Color.green))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                if isLoginMode && !isResetMode {
                    Button("Forgot Password?") {
                        isResetMode = true
                        errorMessage = nil
                        infoMessage = nil
                    }
                    .foregroundColor(.blue)
                    .padding(.top, 5)
                }

                if isResetMode {
                    Button("Back to Login") {
                        isResetMode = false
                        errorMessage = nil
                        infoMessage = nil
                    }
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                }

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }

    var viewTitle: String {
        if isResetMode {
            return "Reset Password"
        } else {
            return isLoginMode ? "Log In" : "Create Account"
        }
    }

    func handleAuth() {
        errorMessage = nil
        infoMessage = nil

        if isLoginMode {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    isLoggedIn = true
                    isAdmin = (email == "admin@rushutk.com")
                }
            }
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    isLoggedIn = true
                    isAdmin = (email == "admin@rushutk.com")
                }
            }
        }
    }

    func sendResetPassword() {
        errorMessage = nil
        infoMessage = nil

        if email.isEmpty {
            errorMessage = "Please enter your email."
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                infoMessage = "A reset email has been sent."
            }
        }
    }
}

