//
//  ChannelItemView.swift
//  Chatty
//
//  Created by Phil Tran on 21/06/2024.
//

import SwiftUI

struct ChannelItemView: View {
    let channel: ChannelItem

    var body: some View {
        HStack(spacing: 12) {
            CircularProfileImageView(channel, size: .medium)

            VStack(alignment: .leading, spacing: 4) {
                Text(channel.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.label))
                    .lineLimit(1)
                HStack(spacing: 0) {
                    Text(channel.displayMessage)
                        .lineLimit(1)
                    Text(" · " + channel.lastMessageTimeStamp.dayOrTimeRepresentation)
                        .lineLimit(1)
                        .layoutPriority(1)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundColor(Color(.systemGray))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview {
    ChannelItemView(channel: .placeholder)
}
