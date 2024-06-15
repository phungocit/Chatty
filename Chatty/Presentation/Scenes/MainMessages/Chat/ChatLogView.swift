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
    @Published var count = 0
    @Published var chatMessages = [ChatMessage]()
//        = [
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//            .init(fromId: UUID().uuidString, toId: UUID().uuidString, text: "Lorem\(Int.random(in: 1 ... 100))", timestamp: Date()),
//        ]

    var chatUser: ChatUser?

    private var textToSend: String {
        chatText.isEmpty ? "Like" : chatText
    }

    init(chatUser: ChatUser?) {
        self.chatUser = chatUser

        fetchMessages()
    }

    var firestoreListener: ListenerRegistration?

    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }

                querySnapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        do {
                            let cm = try change.document.data(as: ChatMessage.self)
                            self.chatMessages.append(cm)
                            print("Appending chatMessage in ChatLogView: \(Date())")
                        } catch {
                            print("Failed to decode message: \(error)")
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }

    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toId = chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()

        let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: textToSend, timestamp: Date())

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
            FirebaseConstants.text: textToSend,
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
            FirebaseConstants.text: textToSend,
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
}

struct ChatLogView: View {
    @ObservedObject var vm: ChatLogViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tabBarVisibility = Visibility.hidden
    @State private var isScrollToFirst = false
    @State private var isCollapseButton = false
    private let scrollNamespace = "scroll"
    static let emptyScrollToString = "Empty"

    var body: some View {
        ZStack {
            messagesView
            Text(vm.errorMessage)
        }
        .background(Color.systemBackground)
        .dismissKeyboard()
        .navigationTitle("")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.firestoreListener?.remove()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 4) {
                    BackButton {
                        tabBarVisibility = .visible
                        dismiss()
                    }
                    NavigationLink {} label: {
                        HStack(spacing: 8) {
                            LazyImageView(url: vm.chatUser?.profileImageUrl)
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 0) {
                                Text(vm.chatUser?.name ?? "")
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .foregroundStyle(Color.label)
                                Text("Active now")
                                    .font(.footnote)
                                    .lineLimit(1)
                                    .foregroundStyle(Color.systemGray)
                            }
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {} label: {
                        Image("phone")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundStyle(Color.greenCustom)
                    }
                    Button {} label: {
                        Image("cinema")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 27, height: 22)
                            .foregroundStyle(Color.greenCustom)
                    }
                }
            }
        }
        .toolbar(tabBarVisibility, for: .tabBar)
        .toolbarBackground(isScrollToFirst ? .hidden : .visible, for: .navigationBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
        }
    }

    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                            .id(message.id)
                    }
                    HStack { Spacer() }
                        .background(Color.red)
                        .id(Self.emptyScrollToString)
                }
                .onReceive(vm.$count) { _ in
                    scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                }
                .background(
                    GeometryReader {
                        Color.clear
                            .preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named(scrollNamespace)).origin.y
                            )
                    }
                )
                .onPreferenceChange(ViewOffsetKey.self) {
                    isScrollToFirst = $0 <= 0
                }
            }
        }
        .coordinateSpace(name: scrollNamespace)
    }

    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            if isCollapseButton {
                BackButton {
                    isCollapseButton = false
                }
                .rotationEffect(.init(degrees: 180))
            } else {
                HStack(spacing: 4) {
                    Button {} label: {
                        ZStack {
                            Image("more")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.greenCustom)
                        }
                        .frame(width: 36, height: 36)
                    }
                    Button {} label: {
                        ZStack {
                            Image("camera")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23, height: 23)
                                .foregroundStyle(Color.greenCustom)
                        }
                        .frame(width: 36, height: 36)
                    }
                    Button {} label: {
                        ZStack {
                            Image("photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 21, height: 21)
                                .foregroundStyle(Color.greenCustom)
                        }
                        .frame(width: 36, height: 36)
                    }
                    Button {} label: {
                        ZStack {
                            Image("mic")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 21)
                                .foregroundStyle(Color.greenCustom)
                        }
                        .frame(width: 36, height: 36)
                    }
                }
            }

            ZStack {
                if vm.chatText.isEmpty {
                    DescriptionPlaceholder()
                        .padding(.horizontal, 8)
                }
                TextEditor(text: $vm.chatText)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 8)
            }
            .background(Color.systemGray5)
            .clipShape(Capsule())
            .frame(height: 40)

            Button {
                vm.handleSend()
            } label: {
                ZStack {
                    Image(vm.chatText.isEmpty ? "like" : "sent")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: vm.chatText.isEmpty ? 24 : 20,
                            height: vm.chatText.isEmpty ? 24 : 20
                        )
                        .foregroundStyle(Color.greenCustom)
                        .animation(.interactiveSpring(duration: 0.3), value: vm.chatText.isEmpty)
                }
                .frame(width: 36, height: 36)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isCollapseButton)
        .onChange(of: vm.chatText) { _ in
            isCollapseButton = true
        }
        .padding(.horizontal)
        .background(Color.systemBackground)
    }
}

struct MessageView: View {
    let message: ChatMessage

    var body: some View {
        VStack(spacing: 2) {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    Text(message.text)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.greenCustom)
                        .cornerRadius(8)
                }
            } else {
                HStack {
                    Text(message.text)
                        .foregroundStyle(Color.label)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.systemGray5)
                        .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Aa")
                .font(.body)
                .foregroundStyle(Color.systemGray)
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ChatLogView(vm: .init(chatUser: .init(uid: UUID().uuidString, email: "email", name: "Name", profileImageUrl: "https://images.pexels.com/photos/96938/pexels-photo-96938.jpeg?cs=srgb&dl=pexels-francesco-ungaro-96938.jpg&fm=jpg")))
    }
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
