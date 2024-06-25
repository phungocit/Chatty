//
//  PeopleViewModel.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import FirebaseAuth
import Foundation

class PeopleViewModel: ObservableObject {
    @Published var isShowLoading = false
    @Published private(set) var users = [UserItem]()
    @Published var channelCreateState: (isNavigateToChatRoom: Bool, newChannel: ChannelItem?) = (false, nil)
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "Uh Oh")

    private let channelService = ChannelService()
    private var lastCursor: String?
    private let currentUser: UserItem

    var isPaginatable: Bool {
        !users.isEmpty
    }

    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        Task {
            isShowLoading = true
            await fetchUsers()
        }
    }

    func createDirectChannel(_ chatPartner: UserItem) {
        Task {
            let result = await channelService.createDirectChannel(
                chatPartner.id,
                members: [chatPartner],
                currentUser: currentUser
            )
            switch result {
            case .success(let channel):
                channelCreateState.isNavigateToChatRoom = true
                channelCreateState.newChannel = channel
            case .failure(let failure):
                showError("Sorry! Something went wrong while we were trying to setup your chat.")
                print("Failed to create a Direct Channel at ChatPartnerPickerViewModel: \(failure.localizedDescription)")
            }
        }
    }

    @MainActor
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginateUsers(lastCursor: lastCursor, pageSize: 5)
            var fetchedUsers = userNode.users
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            fetchedUsers = fetchedUsers.filter { $0.uid != currentUid }
            users.append(contentsOf: fetchedUsers)
            lastCursor = userNode.currentCursor
            isShowLoading = false
            print("lastCursor: \(lastCursor ?? "") \(users.count)")
        } catch {
            isShowLoading = false
            showError("Sorry! Something went wrong while we were fetching user list.")
            print("💿 Failed to fetch users in PeopleViewModel:", error.localizedDescription)
        }
    }
}

private extension PeopleViewModel {
    func showError(_ errorMessage: String) {
        errorState.errorMessage = errorMessage
        errorState.showError = true
    }
}
