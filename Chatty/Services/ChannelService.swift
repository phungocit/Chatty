//
//  ChannelService.swift
//  Chatty
//
//  Created by Foo on 25/06/2024.
//

import Firebase
import Foundation

final class ChannelService {
    typealias ChannelId = String
    func checkDirectChannelExist(with chatPartnerId: String) async -> ChannelId? {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let snapshot = try? await FirebaseConstants.UserDirectChannels.child(currentUid).child(chatPartnerId).getData(),
              snapshot.exists()
        else { return nil }

        let directMessageDict = snapshot.value as? [String: Bool] ?? [:]
        let channelId = directMessageDict.compactMap { $0.key }.first
        return channelId
    }

    func createChannel(
        _ channelName: String?,
        partners: [UserItem],
        currentUser: UserItem?
    ) -> Result<ChannelItem, Error> {
        guard !partners.isEmpty else {
            return .failure(ChannelCreationError.noChatPartner)
        }

        guard
            let channelId = FirebaseConstants.ChannelsRef.childByAutoId().key,
            let currentUid = Auth.auth().currentUser?.uid,
            let messageId = FirebaseConstants.MessagesRef.childByAutoId().key
        else {
            return .failure(ChannelCreationError.failedToCreateUniqueIds)
        }

        let timeStamp = Date().timeIntervalSince1970
        var membersUids = partners.compactMap { $0.uid }
        membersUids.append(currentUid)

        let newChannelBroadcast = AdminMessageType.channelCreation.rawValue

        var channelDict: [String: Any] = [
            .id: channelId,
            .lastMessage: newChannelBroadcast,
            .creationDate: timeStamp,
            .lastMessageTimeStamp: timeStamp,
            .membersUids: membersUids,
            .membersCount: membersUids.count,
            .adminUids: [currentUid],
            .createdBy: currentUid
        ]

        if let channelName = channelName, !channelName.isEmptyOrWhiteSpace {
            channelDict[.name] = channelName
        }

        let messageDict: [String: Any] = [.type: newChannelBroadcast, .timeStamp: timeStamp, .ownerUid: currentUid]

        FirebaseConstants.ChannelsRef.child(channelId).setValue(channelDict)
        FirebaseConstants.MessagesRef.child(channelId).child(messageId).setValue(messageDict)

        membersUids.forEach { userId in
            /// keeping an index of the channel that a specific user belongs to
            FirebaseConstants.UserChannelsRef.child(userId).child(channelId).setValue(true)
        }

        /// Makes sure that a direct channel is unique
        if partners.count == 1 {
            let chatPartner = partners[0]
            FirebaseConstants.UserDirectChannels.child(currentUid).child(chatPartner.uid).setValue([channelId: true])
            FirebaseConstants.UserDirectChannels.child(chatPartner.uid).child(currentUid).setValue([channelId: true])
        }

        var newChannelItem = ChannelItem(channelDict)
        // MARK: Add current User to channel member
        newChannelItem.members = partners
        if let currentUser {
            newChannelItem.members.append(currentUser)
        }
        return .success(newChannelItem)
    }

    func createDirectChannel(
        _ chatPartnerId: String,
        members: [UserItem],
        currentUser: UserItem?
    ) async -> Result<ChannelItem, Error> {
        // if existing DM, get the channel
        if let channelId = await checkDirectChannelExist(with: chatPartnerId),
           let snapshot = try? await FirebaseConstants.ChannelsRef.child(channelId).getData()
        {
            let channelDict = snapshot.value as? [String: Any] ?? [:]
            var directChannel = ChannelItem(channelDict)
            // MARK: Add current User to channel member
            directChannel.members = members
            if let currentUser {
                directChannel.members.append(currentUser)
            }
            // completion(directChannel)
            return .success(directChannel)
        } else {
            // create a new DM with the user
            let channelCreation = createChannel(nil, partners: [], currentUser: nil)
            switch channelCreation {
            case .success(let channel):
                return .success(channel)
            case .failure(let failure):
                print("Failed to create a Direct Channel: \(failure.localizedDescription)")
                return .failure(ChannelCreationError.noChatPartner)
            }
        }
    }
}
