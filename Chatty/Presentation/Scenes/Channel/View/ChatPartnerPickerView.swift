//
//  ChatPartnerPickerView.swift
//  Chatty
//
//  Created by Foo on 21/06/2024.
//

import SwiftUI

struct ChatPartnerPickerView: View {
    var onCreate: (_ newChannel: ChannelItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatPartnerPickerViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack(path: $viewModel.navStack) {
            List {
                Group {
                    ForEach(ChatPartnerPickerOption.allCases) { item in
                        HeaderItemView(item: item) {
                            guard item == ChatPartnerPickerOption.newGroup else { return }
                            viewModel.navStack.append(.groupPartnerPicker)
                        }
                    }

                    Text("Suggested")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.systemGray))

                    ForEach(viewModel.users, id: \.id) { user in
                        ChatPartnerRowView(user: user)
                            .id(user.id)
                            .onTapGesture {
                                viewModel.createDirectChannel(user, completion: onCreate)
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
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "To:"
            )
            .navigationTitle("New message")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ChannelCreationRoute.self) { route in
                destinationView(for: route)
            }
            .toolbar {
                leadingNavItem
            }
            .alert(isPresented: $viewModel.errorState.showError) {
                Alert(
                    title: Text("Uh Oh 😕"),
                    message: Text(viewModel.errorState.errorMessage),
                    dismissButton: .default(Text("Ok"))
                )
            }
            .onAppear {
                viewModel.deSelectAllChatPartners()
            }
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

extension ChatPartnerPickerView {
    @ViewBuilder
    private func destinationView(for route: ChannelCreationRoute) -> some View {
        switch route {
        case .groupPartnerPicker:
            GroupPartnerPickerView(viewModel: viewModel)
        case .setUpGroupChat:
            NewGroupSetUpView(viewModel: viewModel, onCreate: onCreate)
        }
    }
}

extension ChatPartnerPickerView {
    @ToolbarContentBuilder
    private var leadingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
    }
}

extension ChatPartnerPickerView {
    private struct HeaderItemView: View {
        let item: ChatPartnerPickerOption
        let onTapHandler: () -> Void

        var body: some View {
            Button {
                onTapHandler()
            } label: {
                buttonBody
            }
            .buttonStyle(.plain)
        }

        private var buttonBody: some View {
            HStack(spacing: 12) {
                Image(systemName: item.imageName)
                    .font(.footnote)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
                Text(item.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.label))
                Spacer()
                Image("collapse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 8, height: 13)
                    .foregroundStyle(Color(.systemGray))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }
}

enum ChatPartnerPickerOption: String, CaseIterable, Identifiable {
    case newGroup = "Create a new group"
    case newCommunity = "Community"

    var id: String {
        rawValue
    }

    var title: String {
        rawValue
    }

    var imageName: String {
        switch self {
        case .newGroup:
            return "person.2.fill"
        case .newCommunity:
            return "person.3.fill"
        }
    }
}

#Preview {
    ChatPartnerPickerView { _ in }
}
