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
                    NEWEST NEWSLETTERS
                    """)
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                
                Image("newsletter") // replace with your actual image name
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .padding()
                
                Image("newsletter1") // replace with your actual image name
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .padding()
                
                Image("newsletter2") // replace with your actual image name
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .padding()
                
                   .padding(.bottom, 20)
                
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
            
            VStack(alignment: .leading, spacing: 16) {
                // Title text at the top
                Text("ANNOUNCEMENTS")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Group {
                    Text("• Rush week begins this week!")
                    Text("• Philanthropy event sign-ups are due Friday, AUgust 18th, 2025.")
                    Text("• Please only use UTK emails and no personal emails.")
                    Text("• For more information:")
                        .foregroundColor(.white)
                    Link("Visit studentlife.utk.edu", destination: URL(string: "https://studentlife.utk.edu/gogreek/interfraternity-council/")!)
                        .foregroundColor(.white)
                        .underline()
                }
                .foregroundColor(.white)
                .font(.body)
                .padding(.horizontal)
                // The announcement list
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
                .listStyle(.plain)
                .background(Color.clear)
            }
            .padding(.horizontal)
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
