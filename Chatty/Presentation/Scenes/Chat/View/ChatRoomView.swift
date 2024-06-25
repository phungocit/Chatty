//
//  ChatRoomView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/14/24.
//

import PhotosUI
import SwiftUI

struct ChatRoomView: View {
    let channel: ChannelItem

    @StateObject private var viewModel: ChatRoomViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tabBarVisibility = Visibility.hidden

    init(channel: ChannelItem) {
        self.channel = channel
        _viewModel = StateObject(wrappedValue: ChatRoomViewModel(channel))
    }

    var body: some View {
        MessageListView(viewModel)
            .ignoresSafeArea(edges: .bottom)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(viewModel.photoPreviewState.isShow ? .hidden : .visible, for: .navigationBar)
            .toolbar(tabBarVisibility, for: .tabBar)
            .toolbar {
                leadingNavItems
                trailingNavItems
            }
            .photosPicker(
                isPresented: $viewModel.showPhotoPicker,
                selection: $viewModel.photoPickerItems,
                maxSelectionCount: 5,
                photoLibrary: .shared()
            )
            .safeAreaInset(edge: .bottom) {
                bottomSafeAreaView
            }
            .animation(.easeInOut, value: viewModel.showPhotoPickerPreview)
            .fullScreenCover(isPresented: $viewModel.videoPlayerState.isShow) {
                if let player = viewModel.videoPlayerState.player {
                    MediaPlayerView(player: player) {
                        viewModel.dismissMediaPlayer()
                    }
                }
            }
            .overlay {
                if viewModel.photoPreviewState.isShow, let thumbnail = viewModel.photoPreviewState.thumbnail {
                    WrapperAgrumeView(thumbnail: thumbnail) {
                        viewModel.dismissPhotoPreview()
                    }
                    .ignoresSafeArea()
                    .overlay(alignment: .topTrailing) {
                        ClosePreviewButton(dismissPlayer: viewModel.dismissPhotoPreview)
                    }
                }
            }
    }

    private var bottomSafeAreaView: some View {
        VStack(spacing: 0) {
            if viewModel.showPhotoPickerPreview {
                Divider()
                MediaAttachmentPreview(mediaAttachments: viewModel.mediaAttachments) { action in
                    viewModel.handleMediaAttachmentPreview(action)
                }
            }

            TextInputAreaView(
                textMessage: $viewModel.textMessage,
                isRecording: $viewModel.isRecodingVoiceMessage,
                elapsedTime: $viewModel.elapsedVoiceMessageTime,
                isShowLikeButton: viewModel.isShowLikeButton
            ) { action in
                viewModel.handleTextInputArea(action)
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: Toolbar Items
extension ChatRoomView {
    private var channelTitle: String {
        let maxChar = 20
        let trailingChars = channel.title.count > maxChar ? "..." : ""
        let title = String(channel.title.prefix(maxChar) + trailingChars)
        return title
    }

    @ToolbarContentBuilder
    var leadingNavItems: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: 4) {
                BackButton {
                    tabBarVisibility = .visible
                    dismiss()
                }
                NavigationLink {} label: {
                    HStack(spacing: 8) {
                        CircularProfileImageView(channel, size: .custom(36))
                        VStack(alignment: .leading, spacing: 0) {
                            Text(channelTitle)
                                .font(.body)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .foregroundStyle(Color(.label))
                            Text("Active now")
                                .font(.footnote)
                                .lineLimit(1)
                                .foregroundStyle(Color(.systemGray))
                        }
                    }
                }
            }
        }
    }

    @ToolbarContentBuilder
    var trailingNavItems: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            HStack {
                Button {} label: {
                    Image("phone")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(Color.greenCustom)
                }
                Button {} label: {
                    Image("cinema")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 27, height: 22)
                        .foregroundStyle(Color.greenCustom)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatRoomView(channel: .placeholder)
    }
}
