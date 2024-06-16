//
//  ProfileView.swift
//  Chatty
//
//  Created by Phil Tran on 25/3/2024.
//

import Nuke
import PhotosUI
import SwiftUI

struct ProfileView: View {
    let user: User

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isShowPhotoPicker = false
    @State private var isShowSignOutConfirm = false

    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    isShowPhotoPicker.toggle()
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            if viewModel.profileImage == Image(systemName: "person.fill") {
                                LazyImageView(url: user.profileImageUrl ?? "")
                            } else {
                                viewModel.profileImage
                                    .resizable()
                            }
                        }
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay {
                            if viewModel.isShowLoading {
                                ProgressView()
                                    .tint(Color.systemGray)
                            }
                        }
                        Circle()
                            .fill(Color(.darkGray))
                            .frame(width: 30, height: 30)
                            .overlay {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                            }
                    }
                }

                VStack(spacing: 32) {
                    OptionView(
                        title: "Name",
                        subtitle: user.fullName,
                        imageName: "person.fill",
                        secondSubtitle: "This is not your username or pin. This name will be visible to your Chatty contacts."
                    )
                    OptionView(
                        title: "About",
                        subtitle: "Hey there! I am using Chatty.",
                        imageName: "exclamationmark.circle"
                    )
                }
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            try await UserService.shared.fetchCurrentUser()
                        }
                        dismiss()
                    } label: {
                        Text("Done")
                            .foregroundStyle(Color.label)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowSignOutConfirm.toggle()
                    } label: {
                        Text("Sign out")
                            .foregroundStyle(Color.systemRed)
                    }
                }
            }
            .photosPicker(isPresented: $isShowPhotoPicker, selection: $viewModel.selectedImage)
            .actionSheet(isPresented: $isShowSignOutConfirm) {
                .init(
                    title: Text("Are you sure want to sign out?"),
                    buttons: [
                        .destructive(Text("Sign out")) {
                            AuthService.shared.signOut()
                        },
                        .cancel(),
                    ]
                )
            }
        }
    }
}

struct OptionView: View {
    var title: String
    var subtitle: String
    var imageName: String
    var secondSubtitle = ""
    var canEdit = true

    var body: some View {
        HStack(alignment: secondSubtitle != "" ? .top : .center, spacing: 24) {
            Image(systemName: imageName)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color.systemGray)
                .padding(.top, secondSubtitle != "" ? 12 : 0)
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundStyle(Color.systemGray)
                    .font(.headline)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color.label)
                if secondSubtitle != "" {
                    Text(secondSubtitle)
                        .font(.caption)
                        .foregroundStyle(Color.systemGray)
                        .padding(.top, 1)
                }
            }
            Spacer()
            if canEdit {
                Image(systemName: "pencil")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color.systemGray)
                    .padding(.top, secondSubtitle != "" ? 12 : 0)
            }
        }
        .padding(.leading)
        .padding(.trailing, 16)
    }
}

#Preview {
    ProfileView(user: .MOCK_USER)
}
