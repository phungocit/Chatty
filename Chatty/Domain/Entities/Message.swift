//
//  Message.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Firebase
import FirebaseFirestoreSwift

struct Message: Identifiable, Hashable, Codable {
    @DocumentID var messageId: String?
    let fromId: String
    let toId: String
    let messageText: String
    let timestamp: Timestamp
    let isImage: Bool?
    let isVideo: Bool?
    let isAudio: Bool?
    var user: User?

    var id: String {
        messageId ?? UUID().uuidString
    }

    var chatPartnerId: String {
        isFromCurrentUser ? toId : fromId
    }

    var isFromCurrentUser: Bool {
        fromId == Auth.auth().currentUser?.uid
    }

    var displayContent: String {
        let prefix = isFromCurrentUser ? "You: " : ""
        var text = messageText

        if isImage ?? false {
            text = "Sent picture"
        }
        if isVideo ?? false {
            text = "Sent video"
        }
        if isAudio ?? false {
            text = "Sent voice message"
        }
        return prefix + text
    }

    var timestampString: String {
        timestamp.dateValue().timestampString()
    }

    var timeString: String {
        timestamp.dateValue().timeString()
    }
}
