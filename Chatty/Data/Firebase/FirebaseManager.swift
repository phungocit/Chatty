//
//  FirebaseManager.swift
//  Chatty
//
//  Created by Phil Tran on 11/15/21.
//

import Firebase
import FirebaseStorage
import Foundation

class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore

    var currentUser: ChatUser?

    static let shared = FirebaseManager()

    override init() {
        // FirebaseApp.configure()
        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()

        super.init()
    }
}
