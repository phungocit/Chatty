//
//  ChatPartnerRowView.swift
//  Chatty
//
//  Created by Foo on 21/06/2024.
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
        HStack {
            CircularProfileImageView(user.profileImageUrl, size: .xSmall)

            VStack(alignment: .leading) {
                Text(user.username)
                    .bold()
                    .foregroundStyle(Color.label)

                Text(user.bioUnwrapped)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            trailingItems
        }
    }
}

#Preview {
    ChatPartnerRowView(user: .placeholder)
}
