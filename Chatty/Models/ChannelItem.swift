//
//  ChannelItem.swift
//  Chatty
//
//  Created by Foo on 21/06/2024.
//

import Firebase
import Foundation

struct ChannelItem: Identifiable, Hashable {
    var id: String
    var name: String?
    var lastMessage: String
    var creationDate: Date
    var lastMessageTimeStamp: Date
    var membersCount: Int
    var adminUids: [String]
    var membersUids: [String]
    var members: [UserItem]
    var lastMessageOwnerUid: String
    var lastMessageType: MessageType?
    let createdBy: String

    var isGroupChat: Bool {
        membersCount > 2
    }

    var coverImageUrl: String? {
        if let thumbnailUrl {
            return thumbnailUrl
        }

        if isGroupChat == false {
            return membersExcludingMe.first?.profileImageUrl
        }

        return nil
    }

    var membersExcludingMe: [UserItem] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        return members.filter { $0.uid != currentUid }
    }

    var title: String {
        if let name {
            return name
        }

        if isGroupChat {
            return groupMemberNames
        } else {
            return membersExcludingMe.first?.username ?? "Unknown"
        }
    }

    var displayMessage: String {
        var text = lastMessage

        switch lastMessageType {
        case .photo:
            text = "Sent picture"
        case .video:
            text = "Sent video"
        case .audio:
            text = "Sent voice message"
        default: break
        }

        return senderDisplay + text
    }

    private var senderDisplay: String {
        if lastMessageOwnerUid == Auth.auth().currentUser?.uid ?? "" {
            return "You: "
        }
        if isGroupChat, let member = membersExcludingMe.first(where: { $0.uid == lastMessageOwnerUid }) {
            return member.username + ": "
        }
        return ""
    }

    var isSentByMe: Bool {
        lastMessageOwnerUid == Auth.auth().currentUser?.uid ?? ""
    }

    var isCreatedByMe: Bool {
        createdBy == Auth.auth().currentUser?.uid ?? ""
    }

    var creatorName: String {
        members.first { $0.uid == createdBy }?.username ?? "Someone"
    }

    var allMembersFetched: Bool {
        members.count == membersCount
    }

    static let placeholder = ChannelItem(id: "0", lastMessage: "Hello world", creationDate: Date(), lastMessageTimeStamp: Date(), membersCount: 2, adminUids: [], membersUids: ["1", "2"], members: [.init(uid: "1", username: "Black Panther", email: "blackpanther@test.com"), .init(uid: "2", username: "Spiderman", email: "spiderman@test.com")], lastMessageOwnerUid: "2", lastMessageType: .text, createdBy: "1")

    private var thumbnailUrl: String?

    private var groupMemberNames: String {
//        let membersCount = membersCount - 1
        let fullNames = membersExcludingMe.map { $0.username }

        if membersCount == 2 {
            // username1 and username2
            return fullNames.joined(separator: " and ")
        } else if membersCount > 2 {
            // username1, username2 and 10 others
            let remainingCount = membersCount - 2
            return fullNames.prefix(2).joined(separator: ", ") + " and \(remainingCount) " + "others"
        }

        return "Unknown"
    }
}

extension ChannelItem {
    init(_ dict: [String: Any]) {
        self.id = dict[.id] as? String ?? ""
        self.name = dict[.name] as? String? ?? nil
        self.lastMessage = dict[.lastMessage] as? String ?? ""
        let creationInterval = dict[.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationInterval)
        let lastMsgTimeStampInterval = dict[.lastMessageTimeStamp] as? Double ?? 0
        self.lastMessageTimeStamp = Date(timeIntervalSince1970: lastMsgTimeStampInterval)
        self.membersCount = dict[.membersCount] as? Int ?? 0
        self.adminUids = dict[.adminUids] as? [String] ?? []
        self.thumbnailUrl = dict[.thumbnailUrl] as? String ?? nil
        self.membersUids = dict[.membersUids] as? [String] ?? []
        self.members = dict[.members] as? [UserItem] ?? []
        self.createdBy = dict[.createdBy] as? String ?? ""
        self.lastMessageOwnerUid = dict[.lastMessageOwnerUid] as? String ?? ""
        let type = dict[.lastMessageType] as? String ?? "text"
        self.lastMessageType = MessageType(type) ?? .text
    }
}

extension String {
    static let id = "id"
    static let name = "name"
    static let lastMessage = "lastMessage"
    static let creationDate = "creationDate"
    static let lastMessageTimeStamp = "lastMessageTimeStamp"
    static let membersCount = "membersCount"
    static let adminUids = "adminUids"
    static let membersUids = "membersUids"
    static let thumbnailUrl = "thumbnailUrl"
    static let members = "members"
    static let createdBy = "createdBy"
    static let lastMessageType = "lastMessageType"
    static let lastMessageOwnerUid = "lastMessageOwnerUid"
}
