import SwiftUI

struct MessagesView: View {
    @State private var selectedTab = 0
    private let segments = ["Channels", "Direct Messages"]
    @State private var directChats: [Chat] = [
        Chat(contactName: "Alice", messages: ["Welcome to chat with Alice!"]),
        Chat(contactName: "Bob", messages: ["Welcome to chat with Bob!"])
    ]
    @State private var groupChannels: [Chat] = [
        Chat(contactName: "General Channel", messages: ["Welcome to the General Channel!"])
    ]
    @State private var showingNewChat = false
    @State private var showingNewChannel = false
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Select", selection: $selectedTab) {
                    ForEach(0..<segments.count, id: \.self) { index in
                        Text(segments[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    // Channels list.
                    List {
                        ForEach(groupChannels) { channel in
                            NavigationLink(destination: ChatView(chatTitle: channel.contactName)) {
                                Text(channel.contactName)
                            }
                        }
                    }
                    Button("New Channel") { showingNewChannel = true }
                        .padding()
                } else {
                    // Direct messages list.
                    List {
                        ForEach(directChats) { chat in
                            NavigationLink(destination: ChatView(chatTitle: chat.contactName)) {
                                Text(chat.contactName)
                            }
                        }
                    }
                    Button("New Chat") { showingNewChat = true }
                        .padding()
                }
                Spacer()
            }
            .navigationTitle("Messages")
            .sheet(isPresented: $showingNewChat) {
                NewChatView { newChatName in
                    let newChat = Chat(contactName: newChatName, messages: ["Chat started with \(newChatName)"])
                    directChats.append(newChat)
                    showingNewChat = false
                }
            }
            .sheet(isPresented: $showingNewChannel) {
                NewChannelView { newChannelName in
                    let newChannel = Chat(contactName: newChannelName, messages: ["Channel \(newChannelName) created"])
                    groupChannels.append(newChannel)
                    showingNewChannel = false
                }
            }
        }
    }
}

struct ChatView: View {
    let chatTitle: String
    @State private var messages: [String]
    @State private var newMessage: String = ""
    
    init(chatTitle: String) {
        self.chatTitle = chatTitle
        _messages = State(initialValue: ["Welcome to \(chatTitle)!"])
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                            .padding(.vertical, 2)
                    }
                }
                .padding()
            }
            HStack {
                TextField("Type a message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    if !newMessage.isEmpty {
                        messages.append(newMessage)
                        newMessage = ""
                    }
                }
            }
            .padding()
        }
        .navigationTitle(chatTitle)
    }
}

struct NewChatView: View {
    @Environment(\.dismiss) var dismiss
    @State private var chatName: String = ""
    var onCreate: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Name")) {
                    TextField("Enter contact name", text: $chatName)
                }
            }
            .navigationTitle("New Chat")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        if !chatName.isEmpty {
                            onCreate(chatName)
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

struct NewChannelView: View {
    @Environment(\.dismiss) var dismiss
    @State private var channelName: String = ""
    var onCreate: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Channel Name")) {
                    TextField("Enter channel name", text: $channelName)
                }
            }
            .navigationTitle("New Channel")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        if !channelName.isEmpty {
                            onCreate(channelName)
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

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
