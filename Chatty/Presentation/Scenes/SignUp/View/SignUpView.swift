//
//  SignUpView.swift
//  Chatty
//
//  Created by Phil Tran on 7/6/24.
//

import SwiftUI
import UIKit

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Text("Sign up with Email")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.label)
                Text("Get chatting with friends and family today by signing up for our chat app!")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.systemGray)
                    .padding(.top)
            }
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        AuthenTextFieldView(title: "Your name", inValidText: "Your name must not be empty", isValid: $viewModel.isValidName) {
                            TextField("", text: $viewModel.fullName)
                                .autocapitalization(.words)
                                .textContentType(.name)
                        }
                        AuthenTextFieldView(title: "Your email", inValidText: "Invalid email address", isValid: $viewModel.isValidEmail) {
                            TextField("", text: $viewModel.email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                        }
                        AuthenTextFieldView(title: "Your password", inValidText: "Password must be at least 6 characters", isValid: $viewModel.isValidPassword) {
                            SecureField("", text: $viewModel.password)
                                .textInputAutocapitalization(.never)
                                .textContentType(.password)
                        }
                        AuthenTextFieldView(title: "Confirm password", inValidText: "Confirm password and password must match", isValid: $viewModel.isValidConfirmPassword) {
                            SecureField("", text: $viewModel.confirmPassword)
                                .textInputAutocapitalization(.never)
                                .textContentType(.password)
                        }
                        Text(viewModel.signUpErrorMessage)
                            .lineLimit(nil)
                            .font(.caption)
                            .foregroundStyle(Color.systemRed)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                    .padding(.top, 28)
                }
                .padding(.top)
                .padding(.horizontal)
            }
        }
        .overlay {
            if viewModel.isShowLoading {
                ProgressView()
            }
        }
        .dismissKeyboard()
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.systemBackground)
        .safeAreaInset(edge: .bottom) {
            ZStack {
                Color.systemBackground
                Button {
                    UIApplication.dismissKeyboard()
                    if viewModel.isValidInput && !viewModel.isShowLoading {
                        Task {
                            await viewModel.createUser()
                        }
                    }
                } label: {
                    PrimaryButtonContentView(text: "Create an account")
                }
                .padding(.horizontal)
            }
            .frame(height: 80)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
