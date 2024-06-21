//
//  GroupPartnerPickerView.swift
//  Chatty
//
//  Created by Foo on 21/06/2024.
//

import SwiftUI

struct GroupPartnerPickerView: View {
    @ObservedObject var viewModel: ChatPartnerPickerViewModel

    @State private var searchText = ""

    var body: some View {
        List {
            if viewModel.showSelectedUsers {
                SelectedChatPartnerView(users: viewModel.selectedChatPartners) { user in
                    viewModel.handleItemSelection(user)
                }
            }

            Section {
                ForEach(viewModel.users) { item in
                    Button {
                        viewModel.handleItemSelection(item)
                    } label: {
                        chatPartnerRowView(item)
                    }
                }
            }

            if viewModel.isPaginatable {
                loadMoreUsersView
            }
        }
        .animation(.easeInOut, value: viewModel.showSelectedUsers)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search name or number"
        )
        .toolbar {
            titleView
            trailingNavItem
        }
    }

    private func chatPartnerRowView(_ user: UserItem) -> some View {
        ChatPartnerRowView(user: user) {
            Spacer()
            let isSelected = viewModel.isUserSelected(user)
            let imageName = isSelected ? "checkmark.circle.fill" : "circle"
            let foregroundStyle = isSelected ? Color.blue : Color(.systemGray4)
            Image(systemName: imageName)
                .foregroundStyle(foregroundStyle)
                .imageScale(.large)
        }
    }

    private var loadMoreUsersView: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .task {
                await viewModel.fetchUsers()
            }
    }
}

extension GroupPartnerPickerView {
    @ToolbarContentBuilder
    private var titleView: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Add Participants")
                    .bold()

                let count = viewModel.selectedChatPartners.count
                let maxCount = ChannelContants.maxGroupParticipants

                Text("\(count)/\(maxCount)")
                    .foregroundStyle(.gray)
                    .font(.footnote)
            }
        }
    }

    @ToolbarContentBuilder
    private var trailingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Next") {
                viewModel.navStack.append(.setUpGroupChat)
            }
            .bold()
            .disabled(viewModel.disableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        GroupPartnerPickerView(viewModel: ChatPartnerPickerViewModel())
    }
}
