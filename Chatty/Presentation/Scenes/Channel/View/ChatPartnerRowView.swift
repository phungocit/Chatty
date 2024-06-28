//
//  ChatPartnerRowView.swift
//  Chatty
//
//  Created by Phil Tran on 21/06/2024.
//

import SwiftUI

struct ChatPartnerRowView<Content: View>: View {
    private let user: UserItem
    private let trailingItems: Content

    init(user: UserItem, @ViewBuilder trailingItems: () -> Content = { EmptyView() }) {
        self.user = user
        self.trailingItems = trailingItems()
    }

    var body: some View {
        HStack(spacing: 12) {
            CircularProfileImageView(user.profileImageUrl, size: .xSmall)

            Text(user.username)
                .font(.headline)
                .foregroundStyle(Color(.label))

            trailingItems
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview {
    ChatPartnerRowView(user: .placeholder)
}
