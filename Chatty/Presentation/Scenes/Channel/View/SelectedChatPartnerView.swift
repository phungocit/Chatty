//
//  SelectedChatPartnerView.swift
//  Chatty
//
//  Created by Phil Tran on 21/06/2024.
//

import SwiftUI

struct SelectedChatPartnerView: View {
    let users: [UserItem]
    let onTapHandler: (_ user: UserItem) -> Void

    private var imageSize = CircularProfileImageView.Size.small

    init(users: [UserItem], onTapHandler: @escaping (_: UserItem) -> Void) {
        self.users = users
        self.onTapHandler = onTapHandler
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                ForEach(users) { item in
                    chatPartnerView(item)
                }
            }
        }
    }

    private func chatPartnerView(_ user: UserItem) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                CircularProfileImageView(user.profileImageUrl, size: imageSize)
            }
            .frame(width: imageSize.dimension + 10, height: imageSize.dimension + 10)
            .overlay(alignment: .topTrailing) {
                cancelImage
            }

            Text(user.username)
                .font(.caption)
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.center)
        }
        .frame(width: imageSize.dimension + 10)
        .contentShape(Rectangle())
        .onTapGesture {
            onTapHandler(user)
        }
    }

    private var cancelImage: some View {
        Image(systemName: "xmark")
            .resizable()
            .frame(width: 8, height: 8)
            .foregroundStyle(Color(.label))
            .fontWeight(.black)
            .padding(5)
            .background(Color(.systemGray5))
            .clipShape(Circle())
    }
}

#Preview {
    SelectedChatPartnerView(users: UserItem.placeholders) { _ in }
}
