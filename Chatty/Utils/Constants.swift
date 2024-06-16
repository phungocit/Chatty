//
//  Constants.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Firebase

enum CollectionPath {
    static let users = "users"
    static let messages = "messages"
    static let latestMessages = "latest-messages"
}

enum FirestoreConstants {
    static let userCollection = Firestore.firestore().collection(CollectionPath.users)
    static let messageCollection = Firestore.firestore().collection(CollectionPath.messages)
    static let latestMessages = Firestore.firestore().collection(CollectionPath.latestMessages)
}

enum StoragePath {
    static let profileImages = "profile_images"
    static let messageImages = "message_images"
    static let messageVideos = "message_videos"
    static let messageAudios = "message_audios"
}
