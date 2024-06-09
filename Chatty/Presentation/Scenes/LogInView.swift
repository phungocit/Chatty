//
//  LogInView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 8/6/24.
//

import SwiftUI

struct LogInView: View {
    @EnvironmentObject private var routingVM: RoutingViewModel
    @State private var isValidEmail = true
    @State private var isValidPassword = true
    @State private var isShowLoading = false
    @State private var isCompleteLogIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var logInErrorMessage = " "

    private var isEnableButton: Bool {
        [
            !isShowLoading,
            isValidEmail,
            isValidPassword,
        ]
        .allSatisfy { $0 }
    }

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Text("Log in to Chatty")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.label)
                Text("Welcome back! Sign in using your social account or email to continue us")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.systemGray)
                    .padding(.top)
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                SocialAccountView()
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(Color.systemGray5)
                        .frame(height: 1)
                    Text("OR")
                        .font(.subheadline)
                        .foregroundStyle(Color.systemGray)
                    Rectangle()
                        .fill(Color.systemGray5)
                        .frame(height: 1)
                }
                .padding(.horizontal, 6)
                .padding(.top, 30)
                ScrollView {
                    VStack(spacing: 20) {
                        AuthenTextFieldView(title: "Your email", inValidText: "Invalid email address", isValid: $isValidEmail) {
                            TextField("", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                        }
                        AuthenTextFieldView(title: "Your password", inValidText: "Password must be at least 6 characters", isValid: $isValidPassword) {
                            SecureField("", text: $password)
                                .textInputAutocapitalization(.never)
                                .textContentType(.password)
                        }

                        Text(logInErrorMessage)
                            .lineLimit(nil)
                            .font(.caption)
                            .foregroundStyle(Color.systemRed)
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
            if isShowLoading {
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
                VStack(spacing: 16) {
                    Button {
                        UIApplication.shared.dismissKeyboard()
                        isValidEmail = email.isValidEmail
                        isValidPassword = password.trimmingCharacters(in: .whitespacesAndNewlines).count >= 6

                        if isEnableButton {
                            logInErrorMessage = " "
                            isShowLoading = true
                            logInWithEmail()
                        }
                    } label: {
                        PrimaryButtonContentView(text: "Log in")
                    }
                    Button {
                        UIApplication.shared.dismissKeyboard()
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
                    routingVM.popView()
                }
            }
        }
    }
}

private extension LogInView {
    func logInWithEmail() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err {
                print("Failed to login user:", err)
                logInErrorMessage = err.localizedDescription
                isShowLoading = false
                return
            }

            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            isShowLoading = false
            routingVM.handleCompleteLogIn()
        }
    }
}

#Preview {
    NavigationStack {
        LogInView()
            .environmentObject(RoutingViewModel())
    }
}
