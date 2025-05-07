import SwiftUI
import Firebase
import FirebaseFirestore

enum QuestionType: String, CaseIterable, Codable {
    case quantitative = "Quantitative (1–5 Scale)"
    case qualitative = "Qualitative (Free Text)"
}

struct FormQuestion: Identifiable, Codable {
    var id = UUID()
    var questionText: String
    var type: QuestionType
}

struct FormResponse: Codable {
    let questionID: UUID
    var answer: String
}

struct PollsView: View {
    // Building the form
    @State private var newQuestionText: String = ""
    @State private var newQuestionType: QuestionType = .quantitative
    @State private var questions: [FormQuestion] = []

    // Answering the form
    @State private var isFormActive = false
    @State private var responses: [UUID: String] = [:]
    @State private var submittedResponses: [FormResponse] = []
    @State private var showConfirmation = false

    var body: some View {
        NavigationView {
            VStack {
                if isFormActive {
                    Form {
                        ForEach(questions) { question in
                            Section(header: Text(question.questionText)) {
                                if question.type == .quantitative {
                                    Picker("Select a number", selection: Binding(
                                        get: { responses[question.id] ?? "" },
                                        set: { responses[question.id] = $0 }
                                    )) {
                                        ForEach(["1", "2", "3", "4", "5"], id: \.self) {
                                            Text($0)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                } else {
                                    TextField("Your response", text: Binding(
                                        get: { responses[question.id] ?? "" },
                                        set: { responses[question.id] = $0 }
                                    ))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }

                        Button("Submit Responses") {
                            submittedResponses = questions.map {
                                FormResponse(questionID: $0.id, answer: responses[$0.id] ?? "")
                            }
                            saveToFirestore()
                            isFormActive = false
                            responses.removeAll()
                            showConfirmation = true
                        }
                        .foregroundColor(.blue)
                    }
                } else {
                    Form {
                        Section(header: Text("Create a New Question")) {
                            TextField("Question text", text: $newQuestionText)

                            Picker("Type", selection: $newQuestionType) {
                                ForEach(QuestionType.allCases, id: \.self) {
                                    Text($0.rawValue)
                                }
                            }

                            Button("Add Question") {
                                guard !newQuestionText.isEmpty else { return }
                                questions.append(FormQuestion(
                                    questionText: newQuestionText,
                                    type: newQuestionType
                                ))
                                newQuestionText = ""
                                newQuestionType = .quantitative
                            }
                        }

                        if !questions.isEmpty {
                            Section(header: Text("Questions in Form")) {
                                ForEach(questions) { q in
                                    HStack {
                                        Text(q.questionText)
                                        Spacer()
                                        Text(q.type.rawValue)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                }
                                .onDelete { indexSet in
                                    questions.remove(atOffsets: indexSet)
                                }

                                Button("Start Form") {
                                    isFormActive = true
                                    responses = [:]
                                }
                                .foregroundColor(.green)
                            }
                        }
                    }
                }

                if showConfirmation {
                    VStack {
                        Text("✅ Form submitted and saved!")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        Button("OK") {
                            showConfirmation = false
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Poll Form")
        }
    }

    func saveToFirestore() {
        let db = Firestore.firestore()
        let responseData: [String: Any] = [
            "timestamp": Timestamp(date: Date()),
            "responses": submittedResponses.map { response in
                [
                    "question": questions.first { $0.id == response.questionID }?.questionText ?? "Unknown",
                    "answer": response.answer
                ]
            }
        ]

        db.collection("pollForms").addDocument(data: responseData) { error in
            if let error = error {
                print("❌ Error saving to Firestore: \(error.localizedDescription)")
            } else {
                print("✅ Poll form saved to Firestore.")
            }
        }
    }
}

