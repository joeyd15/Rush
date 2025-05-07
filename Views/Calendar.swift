import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var currentDate = Date()
    @State private var isPresentingAddEvent = false
    @State private var selectedDate: Date? = nil

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let daySymbols = Calendar.current.shortStandaloneWeekdaySymbols
    
    var body: some View {
        NavigationView {
            VStack {
                // Month navigation header.
                HStack {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text(monthYearString(for: currentDate))
                        .font(.headline)
                    Spacer()
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
                
                // Day-of-week header.
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(daySymbols, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // Calendar grid.
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(generateCalendarDays(for: currentDate), id: \.self) { day in
                        if let day = day {
                            Button(action: { selectedDate = day }) {
                                VStack(spacing: 2) {
                                    Text("\(Calendar.current.component(.day, from: day))")
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.primary)
                                    
                                    // Display event dots for the day.
                                    let dayEvents = eventStore.events.filter {
                                        Calendar.current.isDate($0.date, inSameDayAs: day)
                                    }
                                    HStack(spacing: 2) {
                                        ForEach(dayEvents.prefix(3)) { event in
                                            Circle()
                                                .fill(event.eventColor)
                                                .frame(width: 6, height: 6)
                                        }
                                    }
                                    
                                    // Add red dot if there is an announcement.
                                    let dayAnnouncements = eventStore.announcements.filter {
                                        Calendar.current.isDate($0.date, inSameDayAs: day)
                                    }
                                    if !dayAnnouncements.isEmpty {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                .padding(4)
                                .background(
                                    (selectedDate != nil && Calendar.current.isDate(selectedDate!, inSameDayAs: day)) ?
                                    Color.gray.opacity(0.3) : Color.clear
                                )
                                .cornerRadius(4)
                            }
                        } else {
                            Text("")
                                .frame(maxWidth: .infinity, minHeight: 40)
                        }
                    }
                }
                .padding(.horizontal)
                
                Button("Add Event") { isPresentingAddEvent = true }
                    .padding()
                    .buttonStyle(.borderedProminent)
                
                if let selectedDay = selectedDate {
                    let dayEvents = eventStore.events.filter {
                        Calendar.current.isDate($0.date, inSameDayAs: selectedDay)
                    }
                    VStack(alignment: .leading) {
                        Text("Events for \(formattedDate(selectedDay)):")
                            .font(.headline)
                            .padding(.top)
                        if dayEvents.isEmpty {
                            Text("No events for this day.")
                                .padding(.vertical, 4)
                        } else {
                            ForEach(dayEvents) { event in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(event.title)
                                            .font(.subheadline)
                                            .bold()
                                        Spacer()
                                        Text(timeString(from: event.date))
                                            .font(.caption)
                                    }
                                    Text(event.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(6)
                                .background(RoundedRectangle(cornerRadius: 4)
                                                .stroke(event.eventColor, lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Calendar")
            .sheet(isPresented: $isPresentingAddEvent) {
                AddEventView(defaultDate: selectedDate ?? Date()) { newEvent in
                    eventStore.events.append(newEvent)
                    isPresentingAddEvent = false
                }
            }
        }
    }
    
    // Helper functions.
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func generateCalendarDays(for date: Date) -> [Date?] {
        var days: [Date?] = []
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let range = calendar.range(of: .day, in: .month, for: date) else { return days }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        for _ in 1..<firstWeekday { days.append(nil) }
        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(dayDate)
            }
        }
        return days
    }
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    let defaultDate: Date
    @State private var eventTitle: String = ""
    @State private var eventDate: Date
    @State private var eventDescription: String = ""
    @State private var eventColor: Color = .blue
    var onSave: (CalendarEvent) -> Void
    
    init(defaultDate: Date, onSave: @escaping (CalendarEvent) -> Void) {
        self.defaultDate = defaultDate
        self.onSave = onSave
        _eventDate = State(initialValue: defaultDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Title")) {
                    TextField("Enter event title", text: $eventTitle)
                }
                Section(header: Text("Event Date & Time")) {
                    DatePicker("Select date and time", selection: $eventDate)
                        .datePickerStyle(.compact)
                }
                Section(header: Text("Description")) {
                    TextEditor(text: $eventDescription)
                        .frame(minHeight: 80)
                }
                Section(header: Text("Event Color")) {
                    ColorPicker("Choose color", selection: $eventColor)
                }
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !eventTitle.isEmpty {
                            let newEvent = CalendarEvent(
                                id: UUID(),
                                date: eventDate,
                                title: eventTitle,
                                description: eventDescription,
                                eventColor: eventColor
                            )
                            onSave(newEvent)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView().environmentObject(EventStore())
    }
}
