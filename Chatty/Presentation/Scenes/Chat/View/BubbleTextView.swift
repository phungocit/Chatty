//
//  BubbleTextView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/14/24.
//

import SwiftUI

struct BubbleTextView: View {
    let item: MessageItem

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if item.showPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl, size: .xMini)
            }

            Text(item.text)
                .foregroundStyle(item.foregroundColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(item.backgroundColor)
                .applyTail(item.direction)
                .contextMenu {
                    Button {} label: {
                        Label("ContextMenu", systemImage: "heart")
                    }
                }
        }
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.trailingPadding)
    }

    private var timeStampTextView: some View {
        Text(item.timeStamp.formatToTime)
            .font(.footnote)
            .foregroundStyle(.gray)
    }
}

#Preview {
    ScrollView {
        BubbleTextView(item: .sentPlaceholder)
        BubbleTextView(item: .receivedPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.4))
}
