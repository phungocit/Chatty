//
//  GroupPartnerPickerView.swift
//  Chatty
//
//  Created by Foo on 21/06/2024.
//

import SwiftUI

struct GroupPartnerPickerView: View {
    @ObservedObject var viewModel: ChatPartnerPickerViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var isShowDiscardGroupConfirm = false

    var body: some View {
        VStack {
            if viewModel.isShowSelectedUsers {
                SelectedChatPartnerView(users: viewModel.selectedChatPartners) { user in
                    viewModel.handleItemSelection(user)
                }
                .padding(.horizontal)
            }
            List {
                Group {
                    Text("Suggested")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.systemGray))

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
                .listRowInsets(.init(top: 10, leading: 16, bottom: 10, trailing: 16))
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        .animation(.easeInOut, value: viewModel.isShowSelectedUsers)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search"
        )
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            leadingNavItem
            titleView
            trailingNavItem
        }
        .alert("Discard group?", isPresented: $isShowDiscardGroupConfirm) {
            Button("Discard group") {
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("If you quite before creating your group, your changes won't be saved")
        }
    }

    private func chatPartnerRowView(_ user: UserItem) -> some View {
        ChatPartnerRowView(user: user) {
            Spacer()
            let isSelected = viewModel.isUserSelected(user)
            let imageName = isSelected ? "checkmark.circle.fill" : "circle"
            let foregroundStyle = isSelected ? Color.greenCustom : Color(.systemGray4)
            Image(systemName: imageName)
                .foregroundStyle(foregroundStyle)
                .imageScale(.large)
        }
    }

    private var loadMoreUsersView: some View {
        ProgressView()
            .tint(Color(.systemGray))
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .task {
                await viewModel.fetchUsers()
            }
    }
}

extension GroupPartnerPickerView {
    @ToolbarContentBuilder
    private var leadingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                if !viewModel.isDisableNextButton {
                    isShowDiscardGroupConfirm = true
                } else {
                    dismiss()
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var titleView: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Add participant")
                    .bold()

                let count = viewModel.selectedChatPartners.count
                let maxCount = ChannelConstants.maxGroupParticipants

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
            .disabled(viewModel.isDisableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        GroupPartnerPickerView(viewModel: ChatPartnerPickerViewModel())
    }
}
