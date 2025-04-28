import SwiftUI

struct PollsView: View {
    @State private var currentPoll: Poll? = nil
    @State private var pollHistory: [Poll] = []
    @State private var pollQuestion: String = ""
    @State private var pollOptions: [String] = ["", ""]
    @State private var hasVoted: Bool = false
    @State private var selectedOptionIndex: Int? = nil
    @State private var showHistory: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let poll = currentPoll {
                    VStack(spacing: 20) {
                        Text(poll.question)
                            .font(.headline)
                            .padding()
                        
                        if hasVoted {
                            ForEach(0..<poll.options.count, id: \.self) { index in
                                HStack {
                                    Text(poll.options[index])
                                        .frame(width: 100, alignment: .leading)
                                    GeometryReader { geo in
                                        let maxVotes = poll.voteCounts.max() ?? 1
                                        let percentage = CGFloat(poll.voteCounts[index]) / CGFloat(maxVotes)
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: geo.size.width * percentage, height: 20)
                                    }
                                    .frame(height: 20)
                                    Text("\(poll.voteCounts[index])")
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            ForEach(0..<poll.options.count, id: \.self) { index in
                                Button(action: {
                                    selectedOptionIndex = index
                                    vote(poll: poll, for: index)
                                }) {
                                    Text(poll.options[index])
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        if hasVoted, let selectedIndex = selectedOptionIndex {
                            Text("You voted for: \(poll.options[selectedIndex])")
                                .padding()
                        }
                        
                        Button("Reset Poll") {
                            if let poll = currentPoll {
                                pollHistory.append(poll)
                            }
                            currentPoll = nil
                            hasVoted = false
                            pollQuestion = ""
                            pollOptions = ["", ""]
                            selectedOptionIndex = nil
                        }
                        .padding()
                    }
                } else {
                    Form {
                        Section(header: Text("Poll Question")) {
                            TextField("Enter your poll question", text: $pollQuestion)
                        }
                        Section(header: Text("Poll Options")) {
                            ForEach(0..<pollOptions.count, id: \.self) { index in
                                TextField("Option \(index + 1)", text: Binding(
                                    get: { pollOptions[index] },
                                    set: { pollOptions[index] = $0 }
                                ))
                            }
                            Button("Add Option") {
                                pollOptions.append("")
                            }
                        }
                        Button("Start Poll") {
                            if !pollQuestion.isEmpty && pollOptions.filter({ !$0.isEmpty }).count >= 2 {
                                currentPoll = Poll(
                                    question: pollQuestion,
                                    options: pollOptions.filter { !$0.isEmpty },
                                    voteCounts: Array(repeating: 0, count: pollOptions.filter { !$0.isEmpty }.count),
                                    createdDate: Date()
                                )
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(showHistory ? "Hide Poll History" : "Show Poll History") {
                    showHistory.toggle()
                }
                .padding()
                .buttonStyle(.bordered)
                
                if showHistory {
                    List(pollHistory) { poll in
                        VStack(alignment: .leading) {
                            Text(poll.question)
                                .font(.headline)
                            Text("Created on: \(formattedDate(poll.createdDate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Polls")
        }
    }
    
    private func vote(poll: Poll, for index: Int) {
        guard var current = currentPoll else { return }
        current.voteCounts[index] += 1
        currentPoll = current
        hasVoted = true
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct PollsView_Previews: PreviewProvider {
    static var previews: some View {
        PollsView()
    }
}
