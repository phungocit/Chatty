//
//  AuthService.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Firebase
import FirebaseFirestoreSwift
import Foundation

class AuthService {
    @Published var userSession: FirebaseAuth.User?

    static let shared = AuthService()

    init() {
        userSession = Auth.auth().currentUser
        loadCurrentUserData()
    }

    @MainActor
    func signIn(withEmail email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        userSession = result.user
        loadCurrentUserData()
    }

    @MainActor
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        userSession = result.user
        try await uploadUserData(email: email, fullname: fullName, id: result.user.uid)
        loadCurrentUserData()
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            userSession = nil
            UserService.shared.currentUser = nil
        } catch {
            print("failed to sign out with error \(error.localizedDescription)")
        }
    }
}

private extension AuthService {
    func uploadUserData(email: String, fullname: String, id: String) async throws {
        let user = User(fullName: fullname, email: email)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await Firestore.firestore().collection("users").document(id).setData(encodedUser)
    }

    func loadCurrentUserData() {
        Task {
            try await UserService.shared.fetchCurrentUser()
        }
    }
}
