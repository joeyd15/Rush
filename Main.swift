import SwiftUI
import Firebase  // ⬅️ Add this

@main
struct CS340_RealApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("institutionSelected") private var institutionSelected: Bool = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    @StateObject var eventStore = EventStore()

    init() {
        // ✅ Initialize Firebase
        FirebaseApp.configure()

        // Reset institution selection on app launch.
        UserDefaults.standard.set(false, forKey: "institutionSelected")
    }

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()
                    .environmentObject(eventStore)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            } else {
                if !institutionSelected {
                    InitialSelectionView()
                } else {
                    UserLoginView()
                }
            }
        }
    }
}

