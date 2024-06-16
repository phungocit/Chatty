//
//  ProfileViewModel.swift
//  Chatty
//
//  Created by Phil Tran on 26/3/2024.
//

import Combine
import Firebase
import Foundation
import PhotosUI
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isShowLoading = false
    @Published var profileImage = Image(systemName: "person.fill")

    @Published var selectedImage: PhotosPickerItem? {
        didSet {
            Task {
                await loadImage(fromItem: selectedImage)
            }
        }
    }

    private var uiImage: UIImage?
    private var cancellables = Set<AnyCancellable>()

    init() {
        UserService.shared.$currentUser
            .sink { [weak self] currentUser in
                self?.user = currentUser
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        isShowLoading = true
        self.uiImage = uiImage
        profileImage = Image(uiImage: uiImage)
        do {
            try await updateProfileImage()
            isShowLoading = false
        } catch {
            print("Failed to update profile image:", error)
            isShowLoading = false
        }
    }

    private func updateProfileImage() async throws {
        guard let image = uiImage else { return }
        guard let imageUrl = try? await ImageService.uploadImage(image) else { return }
        try await UserService.shared.updateUserProfileImage(withImageUrl: imageUrl)
    }
}
