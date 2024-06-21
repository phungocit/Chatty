//
//  RootViewModel.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Combine
import Firebase
import Foundation

final class RootViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published private(set) var authState = AuthState.pending

    private var cancellable = Set<AnyCancellable>()

    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        AuthService.shared.$userSession.sink { [weak self] userSession in
            self?.userSession = userSession
        }
        .store(in: &cancellable)

        AuthManager.shared.authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] latestAuthState in
                self?.authState = latestAuthState
            }
            .store(in: &cancellable)
    }
}
