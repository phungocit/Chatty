//
//  NewMessageViewModel.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Firebase
import Foundation

@MainActor
class NewMessageViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var isShowLoading = false

    init() {
        Task {
            await fetchUsers()
        }
    }

    func fetchUsers() async {
        isShowLoading = true
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let users = try await UserService.fetchAllUsers()
            self.users = users.filter { $0.id != uid }
            isShowLoading = false
        } catch {
            print("Failed to fetch all users:", error)
            isShowLoading = false
        }
    }
}
