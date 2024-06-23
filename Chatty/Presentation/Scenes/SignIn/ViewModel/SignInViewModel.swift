//
//  SignInViewModel.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Firebase
import SwiftUI

final class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var signInErrorMessage = " "
    @Published var isValidEmail = true
    @Published var isValidPassword = true
    @Published var isShowLoading = false

    @MainActor
    func signIn() async {
        isShowLoading = true
        signInErrorMessage = " "
        do {
            try await AuthManager.shared.login(with: email, and: password)
            isShowLoading = false
        } catch {
            print("Failed to sign in user:", error.localizedDescription)
            isShowLoading = false
            signInErrorMessage = error.localizedDescription
        }
    }

    var isValidInput: Bool {
        isValidEmail = email.isValidEmail
        isValidPassword = password.trimmingCharacters(in: .whitespacesAndNewlines).count >= 6
        return isValidEmail && isValidPassword
    }
}
