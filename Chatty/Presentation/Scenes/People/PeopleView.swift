//
//  PeopleView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 9/6/24.
//

import SwiftUI

struct PeopleView: View {
    @StateObject private var vm = PeopleViewModel()
    @EnvironmentObject private var routingVM: RoutingViewModel
    @State private var shouldShowLogOutOptions = false
    @State private var shouldNavigateToChatLogView = false

    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(vm.users) { user in
                    Button {
                        chatLogViewModel.chatUser = user
                        chatLogViewModel.fetchMessages()
                        shouldNavigateToChatLogView.toggle()
                    } label: {
                        HStack(spacing: 16) {
                            LazyImageView(url: user.profileImageUrl)
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            Text(user.name)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.systemBackground)
            .padding(.all)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $shouldNavigateToChatLogView) {
            ChatLogView(vm: chatLogViewModel)
            // .environmentObject(routingVM)
        }
        .toolbar(.visible, for: .tabBar)
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
                Text("People")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.label)
            }
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
    }
}

class PeopleViewModel: ObservableObject {
    @Published var users = [ChatUser]()
    @Published var chatUser: ChatUser?
    @Published var errorMessage = ""

    init() {
        fetchCurrentUser()
        fetchAllUsers()
    }

    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            errorMessage = "Could not find firebase uid"
            return
        }

        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user \(error)"
                print("Failed to fetch current user:", error)
                return
            }

            self.chatUser = try? snapshot?.data(as: ChatUser.self)
//            self.chatUser = .init(uid: UUID().uuidString, email: "email", name: "Name", profileImageUrl: "https://images.pexels.com/photos/96938/pexels-photo-96938.jpeg?cs=srgb&dl=pexels-francesco-ungaro-96938.jpg&fm=jpg")
            FirebaseManager.shared.currentUser = self.chatUser
        }
    }

    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }

                documentsSnapshot?.documents.forEach { snapshot in
                    if let user = try? snapshot.data(as: ChatUser.self), user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(user)
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        PeopleView()
    }
}
