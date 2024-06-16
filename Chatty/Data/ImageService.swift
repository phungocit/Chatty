//
//  ImageService.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Firebase
import FirebaseStorage
import Foundation

struct ImageService {
    static func uploadImage(_ image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.25) else { return nil }
        let fileName = UUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "/\(StoragePath.profileImages)/\(fileName)")
        do {
            _ = try await storageRef.putDataAsync(imageData)
            let url = try await storageRef.downloadURL()
            return url.absoluteString
        } catch {
            print("failed to upload image with error \(error)")
            return nil
        }
    }

    static func uploadMessageImage(_ image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.25) else { return nil }
        let fileName = UUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "/\(StoragePath.messageImages)/\(fileName)")
        do {
            _ = try await storageRef.putDataAsync(imageData)
            let url = try await storageRef.downloadURL()
            return url.absoluteString
        } catch {
            print("failed to upload image with error \(error)")
            return nil
        }
    }
}
