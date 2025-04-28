import SwiftUI

struct HomeView: View {
    @AppStorage("fraternityName") var fraternityName: String = "Your Fraternity"
    @EnvironmentObject var eventStore: EventStore
    
    @State private var selectedSegment = 0
    private let segments = ["Active Newsletter", "Announcements"]
    
    var body: some View {
        NavigationView {
            VStack {
                Text(fraternityName)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 16)
                
                Picker("Select", selection: $selectedSegment) {
                    ForEach(0..<segments.count, id: \.self) { index in
                        Text(segments[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .tint(Color.black)
                
                if selectedSegment == 0 {
                    ActiveNewsletterView()
                } else {
                    // Use the shared event store for announcements.
                    AnnouncementsView()
                        .environmentObject(eventStore)
                }
                
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

struct ActiveNewsletterView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                Text("""
                    Active Newsletter content will be displayed here.
                    Update this section with the latest active newsletter details and subscription options.
                    """)
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .navigationTitle("Active Newsletter")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AnnouncementsView: View {
    @EnvironmentObject var eventStore: EventStore
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            List(eventStore.announcements) { announcement in
                VStack(alignment: .leading) {
                    Text(announcement.title)
                        .font(.headline)
                    Text(formattedDate(announcement.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(announcement.content)
                        .font(.body)
                        .padding(.top, 4)
                }
                .padding(4)
            }
        }
        .navigationTitle("Announcements")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(EventStore())
    }
}
