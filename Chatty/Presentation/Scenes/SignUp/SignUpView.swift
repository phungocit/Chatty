//
//  SignUpView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 7/6/24.
//

import SwiftUI
import UIKit

struct SignUpView: View {
    @EnvironmentObject private var routingVM: RoutingViewModel
    @State private var isShowImagePicker = false
    @State private var isValidAvatar = true
    @State private var isValidName = true
    @State private var isValidEmail = true
    @State private var isValidPassword = true
    @State private var isValidConfirmPassword = true
    @State private var isShowLoading = false
    @State private var isCompleteSignUp = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var signUpErrorMessage = " "
    @State private var image: UIImage?

    private var isEnableButton: Bool {
        [
            !isShowLoading,
            isValidAvatar,
            isValidName,
            isValidEmail,
            isValidPassword,
            isValidConfirmPassword,
        ]
        .allSatisfy { $0 }
    }

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
                    Button {
                        isShowImagePicker.toggle()
                    } label: {
                        VStack(spacing: 4) {
                            if let image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(Color.label)
                            }
                            Text("Select an avatar")
                                .font(.subheadline)
                                .foregroundStyle(
                                    isValidAvatar ? Color.systemGray : Color.systemRed
                                )
                        }
                    }
                    VStack(spacing: 20) {
                        AuthenTextFieldView(title: "Your name", inValidText: "Your name must not be empty", isValid: $isValidName) {
                            TextField("", text: $name)
                                .autocapitalization(.words)
                                .textContentType(.name)
                        }
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
                        AuthenTextFieldView(title: "Confirm password", inValidText: "Confirm password and password must match", isValid: $isValidConfirmPassword) {
                            SecureField("", text: $confirmPassword)
                                .textInputAutocapitalization(.never)
                                .textContentType(.password)
                        }
                        Text(signUpErrorMessage)
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
                Button {
                    UIApplication.shared.dismissKeyboard()
                    isValidAvatar = image != nil
                    isValidName = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    isValidEmail = email.isValidEmail
                    isValidPassword = password.trimmingCharacters(in: .whitespacesAndNewlines).count >= 6
                    isValidConfirmPassword = confirmPassword == password

                    if isEnableButton {
                        signUpErrorMessage = " "
                        isShowLoading = true
                        createNewAccount()
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
                    routingVM.popView()
                }
            }
        }
        .sheet(isPresented: $isShowImagePicker) {
            ImagePicker(image: $image)
                .ignoresSafeArea()
        }
    }
}

private extension SignUpView {
    func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err {
                print("Failed to create user:", err)
                signUpErrorMessage = err.localizedDescription
                isShowLoading = false
                return
            }

            print("Successfully created user: \(result?.user.uid ?? "")")
            persistImageToStorage()
        }
    }

    func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid,
              let imageData = image?.jpegData(compressionQuality: 0.5) else {
            return
        }

        let ref = FirebaseManager.shared.storage.reference(withPath: uid)

        ref.putData(imageData, metadata: nil) { _, err in
            if let err {
                signUpErrorMessage = err.localizedDescription
                isShowLoading = false
                return
            }

            ref.downloadURL { url, err in
                if let err {
                    print("Failed to retrieve downloadURL: \(err)")
                    signUpErrorMessage = err.localizedDescription
                    isShowLoading = false
                    return
                }

                guard let url else {
                    isShowLoading = false
                    return
                }

                print("Successfully stored image with url: \(url.absoluteString)")
                storeUserInformation(imageProfileUrl: url)
            }
        }
    }

    func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        let userData = [
            FirebaseConstants.email: email,
            FirebaseConstants.uid: uid,
            FirebaseConstants.profileImageUrl: imageProfileUrl.absoluteString,
            FirebaseConstants.name: name,
        ]
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .document(uid).setData(userData) { err in
                if let err {
                    print(err)
                    signUpErrorMessage = err.localizedDescription
                    isShowLoading = false
                    return
                }

                print("Success")
                isShowLoading = false
                routingVM.handleCompleteLogIn()
            }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(RoutingViewModel())
    }
}
