import SwiftUI

// MARK: - Models

struct Announcement: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let content: String
}

struct CalendarEvent: Identifiable {
    let id: UUID
    let date: Date       // Includes both date and time.
    let title: String
    let description: String
    let eventColor: Color
}

struct Poll: Identifiable {
    let id = UUID()
    let question: String
    var options: [String]
    var voteCounts: [Int]  // Parallel to options array.
    let createdDate: Date
}

struct Chat: Identifiable {
    let id = UUID()
    let contactName: String
    var messages: [String]
}

// MARK: - Shared Data Model

class EventStore: ObservableObject {
    @Published var events: [CalendarEvent] = []
    
    // Compute announcements from events in the current week.
    var announcements: [Announcement] {
        let calendar = Calendar.current
        let today = Date()
        return events.filter {
            calendar.isDate($0.date, equalTo: today, toGranularity: .weekOfYear)
        }
        .map {
            Announcement(date: $0.date, title: $0.title, content: $0.description)
        }
    }
}
