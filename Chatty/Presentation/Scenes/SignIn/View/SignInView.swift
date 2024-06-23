//
//  SignInView.swift
//  Chatty
//
//  Created by Phil Tran on 8/6/24.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Text("Log in to Chatty")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color(.label))
                Text("Welcome back! Sign in using your social account or email to continue us")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(.systemGray))
                    .padding(.top)
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                SocialAccountView()
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                    Text("OR")
                        .font(.subheadline)
                        .foregroundStyle(Color(.systemGray))
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                }
                .padding(.horizontal, 6)
                .padding(.top, 30)
                ScrollView {
                    VStack(spacing: 20) {
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

                        Text(viewModel.signInErrorMessage)
                            .lineLimit(nil)
                            .font(.caption)
                            .foregroundStyle(Color(.systemRed))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                }
                .padding(.top, 28)
            }
            .padding(.top)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay {
            if viewModel.isShowLoading {
                ProgressView()
                    .tint(Color(.systemGray))
            }
        }
        .dismissKeyboard()
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .bottom) {
            ZStack {
                Color(.systemBackground)
                VStack(spacing: 16) {
                    Button {
                        UIApplication.dismissKeyboard()
                        if viewModel.isValidInput && !viewModel.isShowLoading {
                            Task {
                                await viewModel.signIn()
                            }
                        }
                    } label: {
                        PrimaryButtonContentView(text: "Log in")
                    }
                    Button {
                        UIApplication.dismissKeyboard()
                    } label: {
                        Text("Forgot password?")
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.greenCustom)
                    }
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
        SignInView()
    }
}
