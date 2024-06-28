//
//  ChatPartnerPickerViewModel.swift
//  Chatty
//
//  Created by Phil Tran on 21/06/2024.
//

import Combine
import Firebase
import Foundation

enum ChannelCreationRoute {
    case groupPartnerPicker
    case setUpGroupChat
}

enum ChannelConstants {
    static let maxGroupParticipants = 12
}

enum ChannelCreationError: Error {
    case noChatPartner
    case failedToCreateUniqueIds
    case failedToCreateChannel
}

@MainActor
final class ChatPartnerPickerViewModel: ObservableObject {
    @Published var navStack = [ChannelCreationRoute]()
    @Published var selectedChatPartners = [UserItem]()
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "Uh Oh")

    @Published private(set) var users = [UserItem]()

    var isShowSelectedUsers: Bool {
        !selectedChatPartners.isEmpty
    }

    var isDisableNextButton: Bool {
        selectedChatPartners.count <= 1
    }

    var isPaginatable: Bool {
        !users.isEmpty
    }

    private let channelService = ChannelService()
    private var subscription: AnyCancellable?
    private var lastCursor: String?
    private var currentUser: UserItem?

    private var isDirectChannel: Bool {
        selectedChatPartners.count == 1
    }

    init() {
        listenForAuthState()
    }

    deinit {
        subscription?.cancel()
        subscription = nil
    }

    // MARK: - Public Methods
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginateUsers(lastCursor: lastCursor, pageSize: 5)
            var fetchedUsers = userNode.users
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            fetchedUsers = fetchedUsers.filter { $0.uid != currentUid }
            users.append(contentsOf: fetchedUsers)
            lastCursor = userNode.currentCursor
            print("lastCursor: \(lastCursor ?? "") \(users.count)")
        } catch {
            print("💿 Failed to fetch users in ChatPartnerPickerViewModel")
        }
    }

    func deSelectAllChatPartners() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selectedChatPartners.removeAll()
        }
    }

    func handleItemSelection(_ item: UserItem) {
        if isUserSelected(item) {
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == item.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
            guard selectedChatPartners.count < ChannelConstants.maxGroupParticipants else {
                let errorMessage = "Sorry, We only allow a Maximum of \(ChannelConstants.maxGroupParticipants) participants in a group chat."
                showError(errorMessage)
                return
            }

            selectedChatPartners.append(item)
        }
    }

    func isUserSelected(_ user: UserItem) -> Bool {
        selectedChatPartners.contains { $0.uid == user.uid }
    }

    func createDirectChannel(_ chatPartner: UserItem, completion: @escaping (_ newChannel: ChannelItem) -> Void) {
        selectedChatPartners.append(chatPartner)

        Task {
            let result = await channelService.createDirectChannel(
                chatPartner.id,
                members: selectedChatPartners,
                currentUser: currentUser
            )
            switch result {
            case .success(let channel):
                completion(channel)
            case .failure(let failure):
                showError("Sorry! Something went wrong while we were trying to setup your chat.")
                print("Failed to create a direct channel at ChatPartnerPickerViewModel: \(failure.localizedDescription)")
            }
        }
    }

    func createGroupChannel(_ groupName: String?, completion: @escaping (_ newChannel: ChannelItem) -> Void) {
        let channelCreation = channelService.createChannel(
            groupName,
            partners: selectedChatPartners,
            currentUser: currentUser
        )
        switch channelCreation {
        case .success(let channel):
            completion(channel)
        case .failure(let failure):
            showError("Sorry! Something went wrong while we were trying to setup your group chat.")
            print("Failed to create a group channel: \(failure.localizedDescription)")
        }
    }
}

// MARK: - Private methods
private extension ChatPartnerPickerViewModel {
    private func listenForAuthState() {
        subscription = AuthManager.shared.authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authState in
                switch authState {
                case .loggedIn(let loggedInUser):
                    self?.currentUser = loggedInUser
                    Task {
                        await self?.fetchUsers()
                    }
                default:
                    break
                }
            }
    }

    private func showError(_ errorMessage: String) {
        errorState.errorMessage = errorMessage
        errorState.showError = true
    }
}
