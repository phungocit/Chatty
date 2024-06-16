//
//  RoutingViewModel.swift
//  Chatty
//
//  Created by Phil Tran on 8/6/24.
//

import Foundation

final class RoutingViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var authenPath = [RoutingPath]()
    @Published var mainMessagePath = [RoutingPath]()

    init() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoggedIn = FirebaseManager.shared.auth.currentUser?.uid != nil
        }
    }

    func popView() {
        _ = mainMessagePath.popLast()
        _ = authenPath.popLast()
    }

    func handleCompleteLogIn() {
        isLoggedIn = true
        authenPath.removeAll()
        mainMessagePath.removeAll()
    }

    func handleSignOut() {
        try? FirebaseManager.shared.auth.signOut()
        isLoggedIn = false
        authenPath.removeAll()
        mainMessagePath.removeAll()
    }
}

enum RoutingPath: Hashable, Codable {
    case onBoarding
    case signUp
    case logIn
    case mainMessage
}
