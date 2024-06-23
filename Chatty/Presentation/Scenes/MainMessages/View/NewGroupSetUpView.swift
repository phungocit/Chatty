//
//  NewGroupSetUpView.swift
//  Chatty
//
//  Created by Foo on 21/06/2024.
//

import SwiftUI

struct NewGroupSetUpView: View {
    @ObservedObject var viewModel: ChatPartnerPickerViewModel
    var onCreate: (_ newChannel: ChannelItem) -> Void

    @State private var channelName = ""

    var body: some View {
        List {
            Section {
                channelSetUpHeaderView
            }

            Section {
                Text("Disappearing Messages")
                Text("Group Permissions")
            }

            Section {
                SelectedChatPartnerView(users: viewModel.selectedChatPartners) { user in
                    viewModel.handleItemSelection(user)
                }
            } header: {
                let count = viewModel.selectedChatPartners.count
                let maxCount = ChannelContants.maxGroupParticipants

                Text("Participants: \(count) of \(maxCount)")
                    .bold()
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("New Group")
        .toolbar {
            trailingNavItem
        }
    }

    private var channelSetUpHeaderView: some View {
        HStack {
            profileImageView

            TextField(
                "",
                text: $channelName,
                prompt: Text("Group Name (optional)"),
                axis: .vertical
            )
        }
    }

    private var profileImageView: some View {
        Button {} label: {
            ZStack {
                Image(systemName: "camera.fill")
                    .imageScale(.large)
            }
            .frame(width: 60, height: 60)
            .background(Color(.systemGray6))
            .clipShape(Circle())
        }
    }

    @ToolbarContentBuilder
    private var trailingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Create") {
                viewModel.createGroupChannel(channelName, completion: onCreate)
            }
            .bold()
            .disabled(viewModel.disableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        NewGroupSetUpView(viewModel: ChatPartnerPickerViewModel()) { _ in }
    }
}