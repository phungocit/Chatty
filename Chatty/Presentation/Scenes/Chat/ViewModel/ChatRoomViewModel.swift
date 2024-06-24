//
//  ChatRoomViewModel.swift
//  Chatty
//
//  Created by Phil Tran on 22/6/24.
//

import Combine
import Foundation
import PhotosUI
import SwiftUI

final class ChatRoomViewModel: ObservableObject {
    @Published var textMessage = ""
    @Published var messages = [MessageItem]()
    @Published var showPhotoPicker = false
    @Published var photoPickerItems = [PhotosPickerItem]()
    @Published var mediaAttachments = [MediaAttachment]()
    @Published var videoPlayerState: (isShow: Bool, player: AVPlayer?) = (false, nil)
    @Published var photoPreviewState: (isShow: Bool, url: URL?) = (false, nil)
    @Published var isRecodingVoiceMessage = false
    @Published var elapsedVoiceMessageTime: TimeInterval = 0
    @Published var scrollToBottomRequest: (scroll: Bool, isAnimated: Bool) = (false, false)

    private(set) var channel: ChannelItem
    private var subscriptions = Set<AnyCancellable>()
    private var currentUser: UserItem?
    private let voiceRecorderService = VoiceRecorderService()

    var showPhotoPickerPreview: Bool {
        !mediaAttachments.isEmpty || !photoPickerItems.isEmpty
    }

    var isShowLikeButton: Bool {
        mediaAttachments.isEmpty && textMessage.isEmptyOrWhiteSpace
    }

    init(_ channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
        onPhotoPickerSelection()
        setUpVoiceRecorderListeners()
    }

    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        currentUser = nil
        voiceRecorderService.tearDown()
    }

    private func listenToAuthState() {
        AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { [weak self] authState in
            guard let self = self else { return }
            switch authState {
            case let .loggedIn(currentUser):
                self.currentUser = currentUser
                if self.channel.allMembersFetched {
                    self.getMessages()
                    print("channel members: \(channel.members.map { $0.username })")
                } else {
                    self.getAllChannelMembers()
                }
            default:
                break
            }
        }
        .store(in: &subscriptions)
    }

    private func setUpVoiceRecorderListeners() {
        voiceRecorderService.$isRecording.receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                self?.isRecodingVoiceMessage = isRecording
            }
            .store(in: &subscriptions)

        voiceRecorderService.$elaspedTime.receive(on: DispatchQueue.main)
            .sink { [weak self] elapsedTime in
                self?.elapsedVoiceMessageTime = elapsedTime
            }
            .store(in: &subscriptions)
    }

    func sendMessage() {
        guard let currentUser else { return }
        if mediaAttachments.isEmpty {
            MessageService.sendTextMessage(to: channel, from: currentUser, textMessage.isEmptyOrWhiteSpace ? "👍" : textMessage) { [weak self] in
                self?.textMessage = ""
                self?.scrollToBottom(isAnimated: true)
            }
        } else {
            sendMultipleMediaMessages(textMessage, attachments: mediaAttachments)
            clearTextInputArea()
        }
    }

    private func clearTextInputArea() {
        mediaAttachments.removeAll()
        photoPickerItems.removeAll()
        textMessage = ""
        UIApplication.dismissKeyboard()
    }

    private func sendMultipleMediaMessages(_ text: String, attachments: [MediaAttachment]) {
        mediaAttachments.forEach { attachment in
            switch attachment.type {
            case .photo:
                sendPhotoMessage(text: text, attachment)
            case .video:
                sendVideoMessage(text: text, attachment)
            case .audio:
                sendAudioMessage(text: text, attachment)
            }
        }
    }

    private func sendPhotoMessage(text: String, _ attachment: MediaAttachment) {
        // Upload the image to storage bucket
        uploadImageToStorage(attachment) { [weak self] imageURL in
            // Store the metadata to our database
            guard let self, let currentUser else { return }
            print("Uploaded image to Storage")
            let uploadParams = MessageUploadParams(
                channel: channel,
                text: text,
                type: .photo,
                attachment: attachment,
                thumbnailURL: imageURL.absoluteString,
                sender: currentUser
            )

            MessageService.sendMediaMessage(to: channel, params: uploadParams) {
                self.scrollToBottom(isAnimated: true)
            }
        }
    }

    private func sendVideoMessage(text: String, _ attachment: MediaAttachment) {
        // Upload the video to storage bucket
        uploadFileToStorage(for: .videoMessage, attachment) { [weak self] videoURL in
            // Upload the video thumbnail
            self?.uploadImageToStorage(attachment) { [weak self] thumbnailURL in
                guard let self, let currentUser else { return }

                let uploadParams = MessageUploadParams(
                    channel: self.channel,
                    text: text,
                    type: .video,
                    attachment: attachment,
                    thumbnailURL: thumbnailURL.absoluteString,
                    videoURL: videoURL.absoluteString,
                    sender: currentUser
                )
                MessageService.sendMediaMessage(to: self.channel, params: uploadParams) { [weak self] in
                    self?.scrollToBottom(isAnimated: true)
                }
            }
        }
    }

    private func sendAudioMessage(text: String, _ attachment: MediaAttachment) {
        // Upload the audio to storage bucket
        uploadFileToStorage(for: .audioMessage, attachment) { [weak self] audioURL in
            guard let self, let currentUser, let audioDuration = attachment.audioDuration else { return }

            let uploadParams = MessageUploadParams(
                channel: self.channel,
                text: text,
                type: .audio,
                attachment: attachment,
                sender: currentUser,
                audioURL: audioURL.absoluteString,
                audioDuration: audioDuration
            )

            MessageService.sendMediaMessage(to: self.channel, params: uploadParams) { [weak self] in
                self?.scrollToBottom(isAnimated: true)
            }
        }
    }

    private func scrollToBottom(isAnimated: Bool) {
        scrollToBottomRequest.scroll = true
        scrollToBottomRequest.isAnimated = isAnimated
    }

    private func uploadImageToStorage(_ attachment: MediaAttachment, completion: @escaping (_ imageURL: URL) -> Void) {
        FirebaseHelper.uploadImage(attachment.thumbnail, for: .photoMessage) { result in
            switch result {
            case let .success(imageURL):
                completion(imageURL)
            case let .failure(error):
                print("Failed to upload image to Storage:", error.localizedDescription)
            }
        } progressHandler: { progress in
            print("UPLOAD IMAGE PROGRESS:", progress)
        }
    }

    private func uploadFileToStorage(
        for uploadType: FirebaseHelper.UploadType,
        _ attachment: MediaAttachment,
        completion: @escaping (_ fileURL: URL) -> Void
    ) {
        guard let fileURL = attachment.fileURL else { return }
        FirebaseHelper.uploadFile(for: uploadType, fileURL: fileURL) { result in
            switch result {
            case let .success(fileURL):
                completion(fileURL)
            case let .failure(error):
                print("Failed to upload file to Storage:", error.localizedDescription)
            }
        } progressHandler: { progress in
            print("UPLOAD FILE PROGRESS:", progress)
        }
    }

    private func getMessages() {
        messages = dummyMessages
        scrollToBottom(isAnimated: false)

        MessageService.getMessages(for: channel) { [weak self] messages in
            self?.messages = messages
            self?.scrollToBottom(isAnimated: false)
            print("messages: \(messages)")
        }
    }

    private func getAllChannelMembers() {
        // I already have current user, and potentially 2 other members so no need to refetch those
        guard let currentUser = currentUser else { return }
        let membersAlreadyFetched = channel.members.compactMap { $0.uid }
        var memberUIDSToFetch = channel.membersUids.filter { !membersAlreadyFetched.contains($0) }
        memberUIDSToFetch = memberUIDSToFetch.filter { $0 != currentUser.uid }

        UserService.getUsers(with: memberUIDSToFetch) { [weak self] userNode in
            guard let self = self else { return }
            self.channel.members.append(contentsOf: userNode.users)
            self.getMessages()
            print("getAllChannelMembers: \(channel.members.map { $0.username })")
        }
    }

    func handleTextInputArea(_ action: TextInputAreaView.UserAction) {
        switch action {
        case .presentMediaPicker:
            showPhotoPicker = true
        case .sendMessage:
            sendMessage()
        case .recordAudio:
            toggleAudioRecorder()
        case .presentCamera, .showEmoji:
            break
        }
    }

    private func toggleAudioRecorder() {
        if voiceRecorderService.isRecording {
            // Stop recording
            voiceRecorderService.stopRecording { [weak self] audioURL, audioDuration in
                self?.createAudioAttachment(from: audioURL, audioDuration)
            }
        } else {
            voiceRecorderService.startRecording()
        }
    }

    private func createAudioAttachment(from audioURL: URL?, _ audioDuration: TimeInterval) {
        guard let audioURL = audioURL else { return }
        let id = UUID().uuidString
        let audioAttachment = MediaAttachment(id: id, type: .audio(audioURL, audioDuration))
        mediaAttachments.insert(audioAttachment, at: 0)
    }

    private func onPhotoPickerSelection() {
        $photoPickerItems.sink { [weak self] photoItems in
            guard let self = self else { return }

            let audioRecordings = mediaAttachments.filter { $0.type == .audio(.stubURL, .stubTimeInterval) }
            self.mediaAttachments = audioRecordings
            Task {
                await self.parsePhotoPickerItems(photoItems)
            }
        }
        .store(in: &subscriptions)
    }

    private func parsePhotoPickerItems(_ photoPickerItems: [PhotosPickerItem]) async {
        for photoItem in photoPickerItems {
            if photoItem.isVideo {
                if let movie = try? await photoItem.loadTransferable(type: VideoPickerTransferable.self), let thumbnailImage = try? await movie.url.generateVideoThumbnail(), let itemIdentifier = photoItem.itemIdentifier {
                    let videoAttachment = MediaAttachment(id: itemIdentifier, type: .video(thumbnailImage, movie.url))
                    mediaAttachments.insert(videoAttachment, at: 0)
                }
            } else {
                guard
                    let data = try? await photoItem.loadTransferable(type: Data.self),
                    let thumbnail = UIImage(data: data),
                    let itemIdentifier = photoItem.itemIdentifier
                else { return }
                let photoAttachment = MediaAttachment(id: itemIdentifier, type: .photo(thumbnail))
                mediaAttachments.insert(photoAttachment, at: 0)
            }
        }
    }

    func dismissMediaPlayer() {
        videoPlayerState.player?.replaceCurrentItem(with: nil)
        videoPlayerState.player = nil
        videoPlayerState.isShow = false
    }

    func showMediaPlayer(_ fileURL: URL) {
        videoPlayerState.isShow = true
        videoPlayerState.player = AVPlayer(url: fileURL)
    }

    func dismissPhotoPreview() {
        photoPreviewState.isShow = false
        photoPreviewState.url = nil
    }

    func showPhotoPreview(_ imageURL: URL?) {
        photoPreviewState.isShow = true
        photoPreviewState.url = imageURL
    }

    func handleMediaAttachmentPreview(_ action: MediaAttachmentPreview.UserAction) {
        switch action {
        case let .play(attachment):
            guard let fileURL = attachment.fileURL else { return }
            showMediaPlayer(fileURL)
        case let .remove(attachment):
            remove(attachment)
            guard let fileURL = attachment.fileURL else { return }
            if attachment.type == .audio(.stubURL, .stubTimeInterval) {
                voiceRecorderService.deleteRecording(at: fileURL)
            }
        }
    }

    private func remove(_ item: MediaAttachment) {
        guard let attachmentIndex = mediaAttachments.firstIndex(where: { $0.id == item.id }) else { return }
        mediaAttachments.remove(at: attachmentIndex)

        guard let photoIndex = photoPickerItems.firstIndex(where: { $0.itemIdentifier == item.id }) else { return }
        photoPickerItems.remove(at: photoIndex)
    }

    private var dummyMessages: [MessageItem] {
        [MessageItem(id: "-O07I1_O8yQYiNerekoa", isGroupChat: false, text: "", type: MessageType.admin(AdminMessageType.channelCreation), ownerUid: "Qdvmf89G0WZZ7I3LGU2jRpKYJc63", timeStamp: ISO8601DateFormatter().date(from: "2024-06-24 03: 31: 09 +0000") ?? Date(), sender: nil, thumbnailUrl: nil, thumbnailWidth: nil, thumbnailHeight: nil, videoURL: nil, audioURL: nil, audioDuration: nil), MessageItem(id: "-O07I4XN01B0b9iGXwzE", isGroupChat: false, text: "", type: MessageType.audio, ownerUid: "Qdvmf89G0WZZ7I3LGU2jRpKYJc63", timeStamp: ISO8601DateFormatter().date(from: "2024-06-24 03: 31: 21 +0000") ?? Date(), sender: nil, thumbnailUrl: nil, thumbnailWidth: nil, thumbnailHeight: nil, videoURL: nil, audioURL: Optional("https://firebasestorage.googleapis.com:443/v0/b/swiftui-firebase-chat-837dc.appspot.com/o/voice_messages%2F32C36F32-070E-4713-929B-388287DA0562?alt=media&token=6388e88d-38d8-45b9-b623-4d8ef22ec985"), audioDuration: 10), MessageItem(id: "-O07I8uPVSbfQTET5eWJ", isGroupChat: false, text: "", type: MessageType.photo, ownerUid: "Qdvmf89G0WZZ7I3LGU2jRpKYJc63", timeStamp: ISO8601DateFormatter().date(from: "2024-06-24 03: 31: 39 +0000") ?? Date(), sender: nil, thumbnailUrl: Optional("https://firebasestorage.googleapis.com:443/v0/b/swiftui-firebase-chat-837dc.appspot.com/o/photo_messages%2F56B49E37-8E29-4F88-BC35-4F99FB7B0AB5?alt=media&token=dadceb2f-ba0e-42af-ac82-c9e921923509"), thumbnailWidth: Optional(667.0), thumbnailHeight: Optional(1000.0), videoURL: nil, audioURL: nil, audioDuration: nil), MessageItem(id: "-O07IHeLYlUCIiiliI76", isGroupChat: false, text: "Ssss", type: MessageType.text, ownerUid: "Qdvmf89G0WZZ7I3LGU2jRpKYJc63", timeStamp: ISO8601DateFormatter().date(from: "2024-06-24 03: 32: 15 +0000") ?? Date(), sender: nil, thumbnailUrl: nil, thumbnailWidth: nil, thumbnailHeight: nil, videoURL: nil, audioURL: nil, audioDuration: nil), MessageItem(id: "-O07Ip-6arGid7JjfnoA", isGroupChat: false, text: "", type: MessageType.video, ownerUid: "uxK6S8h74wUhqDWpWwJ9ITonuw93", timeStamp: ISO8601DateFormatter().date(from: "2024-06-24 03: 34: 35 +0000") ?? Date(), sender: nil, thumbnailUrl: Optional("https://firebasestorage.googleapis.com/v0/b/swiftui-firebase-chat-837dc.appspot.com/o/profile_images%2Ftout.webp?alt=media&token=d11e00a8-97ec-4fe6-8607-5887e3f57bb5"), thumbnailWidth: Optional(760.0), thumbnailHeight: Optional(442.0), videoURL: "https://firebasestorage.googleapis.com/v0/b/swiftui-firebase-chat-837dc.appspot.com/o/video_messages%2FFE2ACABD-896A-48CE-80A2-30FE9050A10B?alt=media&token=4845772d-19ed-4d74-b969-b9565cc3ddae", audioURL: nil, audioDuration: nil), MessageItem(id: "-O07Iq6bXcmlOfPKZhrG", isGroupChat: false, text: "Aaa", type: MessageType.text, ownerUid: "uxK6S8h74wUhqDWpWwJ9ITonuw93", timeStamp: ISO8601DateFormatter().date(from: "2024-06-24 03: 34: 40 +0000") ?? Date(), sender: nil, thumbnailUrl: nil, thumbnailWidth: nil, thumbnailHeight: nil, videoURL: nil, audioURL: nil, audioDuration: nil), MessageItem(id: "-O07Itxr-GQA7cEjEMjN", isGroupChat: false, text: "Aa", type: MessageType.audio, ownerUid: "uxK6S8h74wUhqDWpWwJ9ITonuw93", timeStamp: ISO8601DateFormatter().date(from: "2024-06-24 03: 34: 56 +0000") ?? Date(), sender: nil, thumbnailUrl: nil, thumbnailWidth: nil, thumbnailHeight: nil, videoURL: nil, audioURL: Optional("https://firebasestorage.googleapis.com:443/v0/b/swiftui-firebase-chat-837dc.appspot.com/o/voice_messages%2F27918901-F69E-477A-A4C2-89499954C930?alt=media&token=b9ed869d-f882-4249-9e4d-c88c7144751d"), audioDuration: 5), MessageItem(id: "-O07IyPTxL_mDbwA2iOA", isGroupChat: false, text: "Aaa", type: MessageType.photo, ownerUid: "uxK6S8h74wUhqDWpWwJ9ITonuw93", timeStamp: ISO8601DateFormatter().date(from: "2024-06-24 03: 35: 14 +0000") ?? Date(), sender: .init(uid: "1", username: "Nebula", email: "nebula@test.com", profileImageUrl: "https://firebasestorage.googleapis.com/v0/b/swiftui-firebase-chat-837dc.appspot.com/o/profile_images%2FNebula_Vol._3.webp?alt=media&token=58430050-d2b2-47e2-a40b-8a318a07a102"), thumbnailUrl: Optional("https://firebasestorage.googleapis.com:443/v0/b/swiftui-firebase-chat-837dc.appspot.com/o/photo_messages%2F5F502119-BA9B-484C-A51F-3C5658EAE2D1?alt=media&token=da3c5c75-efa4-4e3d-9421-a277a35a83fc"), thumbnailWidth: Optional(4032.0), thumbnailHeight: Optional(3024.0), videoURL: nil, audioURL: nil, audioDuration: nil)]
    }
}
