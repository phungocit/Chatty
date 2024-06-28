//
//  NewGroupSetUpView.swift
//  Chatty
//
//  Created by Phil Tran on 21/06/2024.
//

import SwiftUI

struct NewGroupSetUpView: View {
    @ObservedObject var viewModel: ChatPartnerPickerViewModel
    var onCreate: (_ newChannel: ChannelItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var channelName = ""

    var body: some View {
        List {
            Group {
                Section {
                    channelSetUpHeaderView
                }

                //            Section {
                //                Text("Disappearing Messages")
                //                Text("Group Permissions")
                //            }

                Section {
                    SelectedChatPartnerView(users: viewModel.selectedChatPartners) { user in
                        viewModel.handleItemSelection(user)
                    }
                } header: {
                    let count = viewModel.selectedChatPartners.count
                    let maxCount = ChannelConstants.maxGroupParticipants

                    Text("Participants: \(count) of \(maxCount)")
                        .bold()
                }
            }
            .listRowInsets(.init(top: 10, leading: 16, bottom: 10, trailing: 16))
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle("New group")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            leadingNavItem
            trailingNavItem
        }
    }

    private var channelSetUpHeaderView: some View {
        HStack {
            profileImageView
            TextField(
                "Group name (optional)",
                text: $channelName,
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
            .background(Color(.systemGray5))
            .clipShape(Circle())
        }
    }

    @ToolbarContentBuilder
    private var leadingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
    }

    @ToolbarContentBuilder
    private var trailingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Create") {
                viewModel.createGroupChannel(channelName, completion: onCreate)
            }
            .bold()
            .disabled(viewModel.isDisableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        NewGroupSetUpView(viewModel: ChatPartnerPickerViewModel()) { _ in }
    }
}
