//
//  ChatView.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @StateObject private var viewModel = ChatViewModel()
    @State private var isShowProfileView = false
    @State private var isShowNewMessageView = false
    @State private var isPushToInboxView = false
    @State private var selectedUser: User?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.latestMessages) { message in
                        Button {
                            if let user = message.user {
                                selectedUser = user
                                isPushToInboxView.toggle()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                LazyImageView(url: message.user?.profileImageUrl ?? "")
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(message.user?.fullName ?? "")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color.label)
                                        .lineLimit(1)
                                    Text(message.displayContent)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                        .foregroundStyle(Color.systemGray)
                                }
                                Spacer()
                                Text(message.timestampString)
                                    .font(.footnote)
                                    .lineLimit(1)
                                    .foregroundColor(Color.systemGray)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.systemBackground)
                .padding(.top, -12)
                .padding([.horizontal, .bottom])
            }
            .overlay {
                if viewModel.isShowLoading {
                    ProgressView()
                        .tint(Color.systemGray)
                }
            }
            .dismissKeyboard()
            .searchable(text: .constant(""), prompt: "Search")
            .toolbar(.visible, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if profileViewModel.user != nil {
                            isShowProfileView.toggle()
                        }
                    } label: {
                        LazyImageView(url: profileViewModel.user?.profileImageUrl ?? "")
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
                        isShowNewMessageView.toggle()
                    } label: {
                        Image("new-message")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.greenCustom)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isPushToInboxView) {
                if let selectedUser {
                    InboxView(user: selectedUser)
                }
            }
            .fullScreenCover(
                isPresented: $isShowProfileView,
                content: {
                    if let user = profileViewModel.user {
                        ProfileView(user: user)
                    }
                }
            )
            .sheet(isPresented: $isShowNewMessageView) {
                NewMessage { user in
                    selectedUser = user
                    isPushToInboxView.toggle()
                }
            }
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(ProfileViewModel())
}
