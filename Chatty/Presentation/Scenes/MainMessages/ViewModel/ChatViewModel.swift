//
//  ChatViewModel.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Combine
import Firebase
import Foundation

final class ChatViewModel: ObservableObject {
    @Published var latestMessages = [Message]()
    @Published var isShowLoading = false

    private var cancellables = Set<AnyCancellable>()
    private let service = InboxService()

    init() {
        isShowLoading = true
        setupSubscribers()
        service.observeLatestMessages()
    }

    private func setupSubscribers() {
        service.$documentChanges.sink { [weak self] changes in
            self?.loadInitialMessages(fromChanges: changes)
        }
        .store(in: &cancellables)
    }

    private func loadInitialMessages(fromChanges changes: [DocumentChange]) {
        var messages = changes.compactMap { try? $0.document.data(as: Message.self) }
        for i in 0 ..< messages.count {
            let message = messages[i]
            UserService.fetchUser(withUid: message.chatPartnerId) { user in
                messages[i].user = user
                if let index = self.latestMessages.lastIndex(where: { $0.user == messages[i].user }) {
                    self.latestMessages.remove(at: index)
                }
                self.latestMessages.insert(messages[i], at: 0)
                if i == messages.count - 1 {
                    self.isShowLoading = false
                }
            }
        }
        if messages.isEmpty {
            isShowLoading = false
        }
    }
}
