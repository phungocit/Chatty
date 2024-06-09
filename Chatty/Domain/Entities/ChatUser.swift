//
//  ChatUser.swift
//  Chatty
//
//  Created by Phil Tran on 11/16/21.
//

import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    let uid, email, name, profileImageUrl: String
}
