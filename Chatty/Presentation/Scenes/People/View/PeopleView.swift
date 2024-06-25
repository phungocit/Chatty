//
//  PeopleView.swift
//  Chatty
//
//  Created by Phil Tran on 9/6/24.
//

import SwiftUI

struct PeopleView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @StateObject private var viewModel: PeopleViewModel
    @State private var isPushToInboxView = false
    @State private var isShowProfileView = false
    @State private var selectedUser: User?
    @State private var currentUser: UserItem

    private let userImageSize = CircularProfileImageView.Size.xSmall
    private let userSpacing = CGFloat(16)

    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        _viewModel = .init(wrappedValue: PeopleViewModel(currentUser))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.users, id: \.id) { user in
                        Button {
                            viewModel.createDirectChannel(user)
                        } label: {
                            ChatPartnerRowView(user: user)
                        }
                        .id(user.id)

                        Divider()
                            .padding(.leading, CircularProfileImageView.Size.xSmall.dimension + 12)
                            .padding(.vertical, 8)
                    }

                    if viewModel.isPaginatable {
                        loadMoreUsersView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .padding(.all)
            }
            .overlay {
                if viewModel.isShowLoading {
                    ProgressView()
                        .tint(Color(.systemGray))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $viewModel.channelCreateState.isNavigateToChatRoom) {
                if let newChannel = viewModel.channelCreateState.newChannel {
                    ChatRoomView(channel: newChannel)
                }
            }
            .toolbar(.visible, for: .tabBar)
            .toolbar {
                leadingNavItem
                principalNavItem
            }
            .fullScreenCover(
                isPresented: $isShowProfileView,
                content: {
                    ProfileView(user: .init(uid: currentUser.uid, fullName: currentUser.username, email: currentUser.email, profileImageUrl: currentUser.profileImageUrl))
                }
            )
            .alert(isPresented: $viewModel.errorState.showError) {
                Alert(
                    title: Text("Uh Oh 😕"),
                    message: Text(viewModel.errorState.errorMessage),
                    dismissButton: .default(Text("Ok"))
                )
            }
        }
    }
}

private extension PeopleView {
    @ToolbarContentBuilder
    private var leadingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                isShowProfileView.toggle()
            } label: {
                CircularProfileImageView(currentUser.profileImageUrl, size: .mini)
            }
        }
    }

    @ToolbarContentBuilder
    private var principalNavItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("People")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color(.label))
        }
    }

    private var loadMoreUsersView: some View {
        ProgressView()
            .tint(Color(.systemGray))
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .task {
                await viewModel.fetchUsers()
            }
    }
}

#Preview {
    PeopleView(.placeholder)
        .environmentObject(ProfileViewModel())
}
