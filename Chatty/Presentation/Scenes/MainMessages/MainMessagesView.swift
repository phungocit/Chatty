//
//  MainMessagesView.swift
//  Chatty
//
//  Created by Phil Tran on 11/13/21.
//

import Firebase
import FirebaseFirestoreSwift
import SwiftUI

class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isLogOut = false

    init() {
//        DispatchQueue.main.async {
//            self.isLogOut = FirebaseManager.shared.auth.currentUser?.uid == nil
//        }

        fetchCurrentUser()

        fetchRecentMessages()
    }

    @Published var recentMessages = [RecentMessage]()

    private var firestoreListener: ListenerRegistration?

    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        firestoreListener?.remove()
        recentMessages.removeAll()

        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print("Failed to listen for recent messages:", error)
                    return
                }

                querySnapshot?.documentChanges.forEach { change in
                    let docId = change.document.documentID

                    if let index = self.recentMessages.firstIndex(where: { rm in
                        rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }

                    do {
                        let rm = try change.document.data(as: RecentMessage.self)
                        self.recentMessages.insert(rm, at: 0)
                    } catch {
                        print("documentChanges:", error)
                    }
                }
            }
    }

    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            errorMessage = "Could not find firebase uid"
            return
        }

        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }

            self.chatUser = try? snapshot?.data(as: ChatUser.self)
            FirebaseManager.shared.currentUser = self.chatUser
        }
    }
}

struct MainMessagesView: View {
    @EnvironmentObject private var routingVM: RoutingViewModel
    @StateObject private var vm = MainMessagesViewModel()
    @State private var shouldShowLogOutOptions = false
    @State private var shouldNavigateToChatLogView = false
    @State private var shouldShowNewMessageScreen = false
    @State private var chatUser: ChatUser?

    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(vm.recentMessages) { recentMessage in
                    Button {
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId

                        chatUser = .init(id: uid, uid: uid, email: recentMessage.email, name: recentMessage.name, profileImageUrl: recentMessage.profileImageUrl)

                        chatLogViewModel.chatUser = chatUser
                        chatLogViewModel.fetchMessages()
                        shouldNavigateToChatLogView.toggle()
                    } label: {
                        HStack(spacing: 12) {
                            LazyImageView(url: recentMessage.profileImageUrl)
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(recentMessage.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.label)
                                    .lineLimit(1)
                                Text(recentMessage.text)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .foregroundStyle(Color.systemGray)
                            }
                            Spacer()
                            Text(recentMessage.timeAgo)
                                .font(.footnote)
                                .lineLimit(1)
                                .foregroundColor(Color.systemGray)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .padding(.top, -12)
            .padding([.horizontal, .bottom])
        }
        .dismissKeyboard()
        .background(Color.systemBackground)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    shouldShowLogOutOptions.toggle()
                } label: {
                    LazyImageView(url: vm.chatUser?.profileImageUrl)
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Chats")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.label)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    shouldShowNewMessageScreen.toggle()
                } label: {
                    Image("new-message")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.label)
                }
            }
        }
        .searchable(text: .constant(""), prompt: "Search")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $shouldNavigateToChatLogView) {
            ChatLogView(vm: chatLogViewModel)
        }
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(
                title: Text("Settings"),
                message: Text("What do you want to do?"),
                buttons: [
                    .destructive(Text("Sign Out")) {
                        routingVM.handleSignOut()
                    },
                    .cancel(),
                ]
            )
        }
        .sheet(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView { user in
                shouldNavigateToChatLogView.toggle()
                chatUser = user
                chatLogViewModel.chatUser = user
                chatLogViewModel.fetchMessages()
            }
        }
    }
}

#Preview {
    RoutingView()
}
