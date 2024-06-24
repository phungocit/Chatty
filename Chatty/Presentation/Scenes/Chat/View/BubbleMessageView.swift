//
//  BubbleMessageView.swift
//  Chatty
//
//  Created by Foo on 24/06/2024.
//

import SwiftUI

struct BubbleMessageView: View {
    let viewModel: ChatRoomViewModel
    let row: Int

    var body: some View {
        let message = viewModel.messages[row]
        HStack(spacing: 0) {
            if message.direction == .sent {
                Spacer()
            }

            switch message.type {
            case .text:
                BubbleTextView(item: message)
            case .video, .photo:
                BubbleMediaView(item: message)
            case .audio:
                BubbleAudioView(item: message)
            case let .admin(adminType):
                switch adminType {
                case .channelCreation:
                    ChannelCreationTextView()
                    if viewModel.channel.isGroupChat {
                        AdminMessageTextView(channel: viewModel.channel)
                    }
                default:
                    Text("UNKNOW")
                }
            }

            if message.direction == .received {
                Spacer()
            }
        }
    }
}

#Preview {
    BubbleMessageView(viewModel: ChatRoomViewModel(.placeholder), row: 0)
}
