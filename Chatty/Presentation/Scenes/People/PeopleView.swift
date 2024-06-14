//
//  PeopleView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 9/6/24.
//

import SwiftUI

struct PeopleView: View {
    @EnvironmentObject private var routingVM: RoutingViewModel
    @State private var shouldShowLogOutOptions = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0 ..< 50) { i in
                    Text("\(i)")
                        .padding()
                }
//                ForEach(vm.recentMessages) { recentMessage in
//                    Button {
//                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
//
//                        chatUser = .init(id: uid, uid: uid, email: recentMessage.email, name: recentMessage.name, profileImageUrl: recentMessage.profileImageUrl)
//
//                        chatLogViewModel.chatUser = chatUser
//                        chatLogViewModel.fetchMessages()
//                        shouldNavigateToChatLogView.toggle()
//                    } label: {
//                        HStack(spacing: 12) {
//                            LazyImageView(url: recentMessage.profileImageUrl)
//                                .scaledToFill()
//                                .frame(width: 60, height: 60)
//                                .clipShape(Circle())
//
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text(recentMessage.name)
//                                    .font(.body)
//                                    .fontWeight(.medium)
//                                    .foregroundStyle(Color.label)
//                                    .lineLimit(1)
//                                Text(recentMessage.text)
//                                    .font(.subheadline)
//                                    .lineLimit(1)
//                                    .foregroundStyle(Color.systemGray)
//                            }
//                            Spacer()
//                            Text(recentMessage.timeAgo)
//                                .font(.footnote)
//                                .lineLimit(1)
//                                .foregroundColor(Color.systemGray)
//                        }
//                    }
//                    .padding(.vertical, 12)
//                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.systemBackground)
            .padding(.top, -12)
            .padding([.horizontal, .bottom])
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar, .navigationBar)
        .toolbarBackground(Color.systemBackground, for: .tabBar, .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    shouldShowLogOutOptions.toggle()
                } label: {
                    LazyImageView(url: "https://images.pexels.com/photos/96938/pexels-photo-96938.jpeg?cs=srgb&dl=pexels-francesco-ungaro-96938.jpg&fm=jpg")
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

#Preview {
    NavigationStack {
        PeopleView()
    }
}
