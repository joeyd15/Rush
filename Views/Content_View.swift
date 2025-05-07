import SwiftUI

struct ContentView: View {
    // Pass the shared event store to children.
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        TabView {
            HomeView()
                .environmentObject(eventStore)
                .tabItem { Label("Home", systemImage: "house") }
            CalendarView()
                .environmentObject(eventStore)
                .tabItem { Label("Calendar", systemImage: "calendar") }
            PollsView()
                .tabItem { Label("Polls", systemImage: "chart.bar.xaxis") }
            MessagesView()
                .tabItem { Label("Messages", systemImage: "message") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .toolbarBackground(
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing),
            for: .tabBar
        )
        .toolbarBackground(.visible, for: .tabBar)
        .accentColor(.yellow)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(EventStore())
    }
}
