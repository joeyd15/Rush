import SwiftUI

@main
struct CS340_RealApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("institutionSelected") private var institutionSelected: Bool = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    // Shared event store.
    @StateObject var eventStore = EventStore()
    
    init() {
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
