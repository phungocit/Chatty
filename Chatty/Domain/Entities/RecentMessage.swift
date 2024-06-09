//
//  RecentMessage.swift
//  Chatty
//
//  Created by Phil Tran on 11/21/21.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let text, email, name: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Date

    var username: String {
        email.components(separatedBy: "@").first ?? email
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
