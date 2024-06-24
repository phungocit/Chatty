//
//  BubbleMediaView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/15/24.
//

import Kingfisher
import SwiftUI

struct BubbleMediaView: View {
    let item: MessageItem

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if item.showPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl, size: .xMini)
            }

            messageMediaView
                .overlay {
                    playButton
                        .opacity(item.type == .video ? 1 : 0)
                }
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

    private var playButton: some View {
        Image(systemName: "play.fill")
            .padding()
            .imageScale(.large)
            .foregroundStyle(.white)
            .background(.black.opacity(0.3))
            .clipShape(Circle())
    }

    private var messageMediaView: some View {
        VStack(alignment: .leading, spacing: 0) {
            KFImage(URL(string: item.thumbnailUrl ?? ""))
                .resizable()
                .placeholder {
                    ProgressView()
                        .tint(Color(.systemGray))
                }
                .scaledToFill()
                .frame(width: item.imageSize.width, height: item.imageSize.height)
                .applyTail(item.direction)

            if !item.text.isEmptyOrWhiteSpace {
                Text(item.text)
                    .foregroundStyle(item.foregroundColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(item.backgroundColor)
                    .applyTail(item.direction)
                    .frame(maxWidth: item.imageSize.width, alignment: .leading)
            }
        }
    }

    private var shareButton: some View {
        Button {} label: {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .padding(10)
                .foregroundStyle(.white)
                .background(Color.gray)
                .background(.thinMaterial)
                .clipShape(Circle())
        }
    }

    private var timeStampTextView: some View {
        HStack {
            Text("11:13 AM")
                .font(.system(size: 12))

            if item.direction == .sent {
//                Image(.seen)
//                    .resizable()
//                    .renderingMode(.template)
//                    .frame(width: 15, height: 15)
            }
        }
        .padding(.vertical, 2.5)
        .padding(.horizontal, 8)
        .foregroundStyle(.white)
        .background(Color(.systemGray3))
        .clipShape(Capsule())
        .padding(12)
    }
}

#Preview {
    ScrollView {
        BubbleMediaView(item: .receivedPlaceholder)
        BubbleMediaView(item: .sentPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(Color.gray.opacity(0.4))
}
