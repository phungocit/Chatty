//
//  PeopleView.swift
//  Chatty
//
//  Created by Phil Tran on 9/6/24.
//

import SwiftUI

struct PeopleView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @StateObject private var viewModel = PeopleViewModel()
    @State private var isPushToInboxView = false
    @State private var isShowProfileView = false
    @State private var selectedUser: User?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.users) { user in
                        Button {
                            selectedUser = user
                            isPushToInboxView.toggle()
                        } label: {
                            HStack(spacing: 16) {
                                LazyImageView(url: user.profileImageUrl)
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                Text(user.fullName)
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
            .navigationDestination(isPresented: $isPushToInboxView) {
                if let selectedUser {
                    InboxView(user: selectedUser)
                }
            }
            .toolbar(.visible, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowProfileView.toggle()
                    } label: {
                        LazyImageView(url: profileViewModel.user?.profileImageUrl ?? "")
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("People")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.label))
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
        }
    }
}

#Preview {
    PeopleView()
        .environmentObject(ProfileViewModel())
}
