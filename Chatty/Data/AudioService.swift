//
//  AudioService.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import FirebaseStorage
import Foundation

struct AudioService {
    static func uploadAudio(recordingURL: URL?, completion: @escaping (String?) -> Void) {
        guard let recordingURL = recordingURL else {
            print("Recording not found")
            completion(nil)
            return
        }
        let fileName = UUID().uuidString
        let metaData = StorageMetadata()
        metaData.contentType = "audio/m4a"
        let audioRef = Storage.storage().reference().child("/\(StoragePath.messageAudios)/\(fileName).m4a")
        audioRef.putFile(from: recordingURL, metadata: metaData) { _, error in
            if let error = error {
                print("Error uploading recording: \(error.localizedDescription)")
            } else {
                print("Recording uploaded successfully")
                // Once uploaded, get the download URL and save it to Firestore
                audioRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    } else {
                        completion(url?.absoluteString)
                    }
                }
            }
        }
    }
}