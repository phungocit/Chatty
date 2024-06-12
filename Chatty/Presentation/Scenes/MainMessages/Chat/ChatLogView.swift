//
//  ChatLogView.swift
//  Chatty
//
//  Created by Phil Tran on 11/18/21.
//

import Firebase
import SwiftUI

class ChatLogViewModel: ObservableObject {
    @Published var chatText = ""
    @Published var errorMessage = ""

    @Published var chatMessages: [ChatMessage] = [
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
        .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1...100))", timestamp: Date()),
    ]

    var chatUser: ChatUser?

    init(chatUser: ChatUser?) {
        self.chatUser = chatUser

        // fetchMessages()
    }

    var firestoreListener: ListenerRegistration?

    func fetchMessages() {
//        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
//        guard let toId = chatUser?.uid else { return }
//        firestoreListener?.remove()
//        chatMessages.removeAll()
//        firestoreListener = FirebaseManager.shared.firestore
//            .collection(FirebaseConstants.messages)
//            .document(fromId)
//            .collection(toId)
//            .order(by: FirebaseConstants.timestamp)
//            .addSnapshotListener { querySnapshot, error in
//                if let error = error {
//                    self.errorMessage = "Failed to listen for messages: \(error)"
//                    print(error)
//                    return
//                }
//
//                querySnapshot?.documentChanges.forEach { change in
//                    if change.type == .added {
//                        do {
//                            let cm = try change.document.data(as: ChatMessage.self)
//                            self.chatMessages.append(cm)
//                            print("Appending chatMessage in ChatLogView: \(Date())")
//                        } catch {
//                            print("Failed to decode message: \(error)")
//                        }
//                    }
//                }
//
//                DispatchQueue.main.async {
//                    self.count += 1
//                }
//            }
    }

    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toId = chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()

        let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, timestamp: Date())

        try? document.setData(from: msg) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }

            print("Successfully saved current user sending message")

            self.persistRecentMessage()

            self.chatText = ""
            self.count += 1
        }

        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()

        try? recipientMessageDocument.setData(from: msg) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }

            print("Recipient saved message as well")
        }
    }

    private func persistRecentMessage() {
        guard let chatUser = chatUser else { return }

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)

        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email,
            FirebaseConstants.name: chatUser.name,
        ] as [String: Any]

        // you'll need to save another very similar dictionary for the recipient of this message...how?

        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }

        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        let recipientRecentMessageDictionary = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
            FirebaseConstants.email: currentUser.email,
            FirebaseConstants.name: currentUser.name,
        ] as [String: Any]

        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }

    @Published var count = 0
}

struct ChatLogView: View {
//    let chatUser: ChatUser?
//
//    init(chatUser: ChatUser?) {
//        self.chatUser = chatUser
//        self.vm = .init(chatUser: chatUser)
//    }
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var routingVM: RoutingViewModel
    @ObservedObject var vm: ChatLogViewModel
    @State var tabBarVisibility = Visibility.hidden
    static let emptyScrollToString = "Empty"

    var body: some View {
        ZStack {
            messagesView
            Text(vm.errorMessage)
        }
        .background(Color.systemBackground)
        .dismissKeyboard()
        .navigationTitle(vm.chatUser?.name ?? "")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.firestoreListener?.remove()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton {
                    tabBarVisibility = .visible
                    dismiss()
                    // routingVM.popView()
                }
            }
//            ToolbarItem(placement: .principal) {
//                Text(vm.chatUser?.name ?? "")
//                    .font(.title3)
//                    .fontWeight(.semibold)
//                    .foregroundStyle(.white)
//                    .navigationBarColor(Color(.darkGray))
//            }
        }
        .toolbar(tabBarVisibility, for: .tabBar)
        .toolbarBackground(.visible, for: .navigationBar)
        //.toolbarBackground(.regularMaterial, for: .navigationBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
                .background(.regularMaterial)
        }
    }

    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                    }
                    HStack { Spacer() }
                        .id(Self.emptyScrollToString)
                }
                .onReceive(vm.$count) { _ in
                    scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                }
            }
        }
    }

    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 20))
                .foregroundColor(Color(.darkGray))
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)

            Button {
                vm.handleSend()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
    }
}

struct MessageView: View {
    let message: ChatMessage

    var body: some View {
        VStack {
//            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundStyle(Color.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            //} else {
                HStack {
                    HStack {
                        Text(message.text)
                            .foregroundStyle(Color.label)
                    }
                    .padding()
                    .background(Color.systemGray5)
                    .cornerRadius(8)
                    Spacer()
                }
            //}
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

#Preview {
    RoutingView()
}
