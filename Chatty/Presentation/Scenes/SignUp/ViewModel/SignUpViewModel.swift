//
//  SignUpViewModel.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Foundation

final class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var fullName = ""
    @Published var signUpErrorMessage = " "
    @Published var isShowLoading = false
    @Published var isValidName = true
    @Published var isValidEmail = true
    @Published var isValidPassword = true
    @Published var isValidConfirmPassword = true

    @MainActor
    func createUser() async {
        isShowLoading = true
        signUpErrorMessage = " "
        do {
            try await AuthManager.shared.createAccount(with: email, and: password, for: fullName)
            isShowLoading = false
        } catch {
            print("Failed to create user:", error)
            signUpErrorMessage = error.localizedDescription
            isShowLoading = false
        }
    }

    var isValidInput: Bool {
        isValidName = !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        isValidEmail = email.isValidEmail
        isValidPassword = password.trimmingCharacters(in: .whitespacesAndNewlines).count >= 6
        isValidConfirmPassword = confirmPassword == password
        return isValidName && isValidEmail && isValidPassword && isValidConfirmPassword
    }
}
