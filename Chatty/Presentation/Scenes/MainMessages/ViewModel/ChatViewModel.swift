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
        // Dispatch Queue for Concurrency: We use a global dispatch queue with a barrier flag to perform the updates concurrently and safely.
        // Avoid Mutating Original Array: Instead of mutating the messages array while fetching users, consider using a map function to create a new array with the user information.
        // Concurrent Updates: The UserService.fetchUser calls are concurrent, and we use queue.async(flags: .barrier) to append to the updatedMessages array safely.
        // Minimized Main Thread Work: Only the necessary UI updates and sorting are performed on the main thread inside the notify block.

        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)

        let messages = changes.compactMap { try? $0.document.data(as: Message.self) }
        var updatedMessages = [Message]()

        for message in messages {
            group.enter()
            UserService.fetchUser(withUid: message.chatPartnerId) { user in
                var updatedMessage = message
                updatedMessage.user = user
                queue.async(flags: .barrier) {
                    updatedMessages.append(updatedMessage)
                    group.leave()
                }
            }
        }

        if messages.isEmpty {
            isShowLoading = false
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            updatedMessages.forEach { message in
                print(message.chatPartnerId)
                if let index = self.latestMessages.lastIndex(where: { $0.chatPartnerId == message.chatPartnerId }) {
                    self.latestMessages.remove(at: index)
                }
                self.latestMessages.insert(message, at: 0)
            }

            self.latestMessages.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
            self.isShowLoading = false
        }
    }

//    private func loadInitialMessages(fromChanges changes: [DocumentChange]) {
//        let messagesDispatchGroup = DispatchGroup()
//        var messages = changes.compactMap { try? $0.document.data(as: Message.self) }
//
//        for i in 0 ..< messages.count {
//            messagesDispatchGroup.enter()
//            UserService.fetchUser(withUid: messages[i].chatPartnerId) { [weak self] user in
//                messages[i].user = user
//                if let index = self?.latestMessages.lastIndex(where: { $0.chatPartnerId == messages[i].chatPartnerId }) {
//                    self?.latestMessages.remove(at: index)
//                }
//                self?.latestMessages.insert(messages[i], at: 0)
//                messagesDispatchGroup.leave()
//            }
//        }
//        if messages.isEmpty {
//            isShowLoading = false
//        }
//
//        messagesDispatchGroup.notify(queue: .main) { [weak self] in
//            self?.isShowLoading = false
//            self?.latestMessages.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
//        }
//    }
}
