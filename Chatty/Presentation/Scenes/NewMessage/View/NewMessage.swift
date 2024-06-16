//
//  NewMessage.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import SwiftUI

struct NewMessage: View {
    let didSelectNewUser: (User) -> Void

    @StateObject private var viewModel = NewMessageViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(viewModel.users) { user in
                    Button {
                        dismiss()
                        didSelectNewUser(user)
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
                        .padding(.horizontal)
                    }
                    Divider()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
            }
            .overlay {
                if viewModel.isShowLoading {
                    ProgressView()
                }
            }
            .navigationTitle("New message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(Color.label)
                    }
                }
            }
        }
    }
}

#Preview {
    NewMessage { _ in }
}
