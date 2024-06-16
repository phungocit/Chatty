//
//  InboxView.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import AVKit
import SwiftUI

struct InboxView: View {
    @ObservedObject var viewModel: InboxViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var tabBarVisibility = Visibility.hidden
    @State private var isShowMediaPicker = false
    @State private var isShowCameraView = false
    @State private var isShowVideoPicker = false
    @State private var isScrollToFirst = false
    @State private var isCollapseButton = false
    private let scrollNamespace = "scroll"

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let emptyScrollToString = "Empty"

    var body: some View {
        messagesView
            .background(Color.systemBackground)
            .dismissKeyboard()
            .navigationTitle("")
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 4) {
                        BackButton {
                            tabBarVisibility = .visible
                            dismiss()
                        }
                        NavigationLink {} label: {
                            HStack(spacing: 8) {
                                LazyImageView(url: viewModel.user.profileImageUrl)
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(viewModel.user.fullName)
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                        .foregroundStyle(Color.label)
                                    Text("Active now")
                                        .font(.footnote)
                                        .lineLimit(1)
                                        .foregroundStyle(Color.systemGray)
                                }
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {} label: {
                            Image("phone")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(Color.greenCustom)
                        }
                        Button {} label: {
                            Image("cinema")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 27, height: 22)
                                .foregroundStyle(Color.greenCustom)
                        }
                    }
                }
            }
            .toolbar(tabBarVisibility, for: .tabBar)
            .toolbarBackground(isScrollToFirst ? .hidden : .visible, for: .navigationBar)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .safeAreaInset(edge: .bottom) {
                chatBottomBar
            }
            .photosPicker(
                isPresented: $isShowMediaPicker,
                selection: $viewModel.selectedMedia,
                matching: .any(of: [.images, .videos])
            )
            .fullScreenCover(isPresented: $isShowCameraView) {
                CameraView()
            }
    }

    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(viewModel.messageGroups) { group in
                        Section {
                            ForEach(group.messages) { message in
                                InboxMessage(message: message)
                                    .id(message.id)
                            }
                        } header: {
                            Text(group.date.chatTimestampString())
                                .font(.footnote)
                                .foregroundStyle(Color.label)
                        }
                    }
                    HStack {
                        Spacer()
                    }
                    .id(Self.emptyScrollToString)
                }
                .onReceive(viewModel.$count) { _ in
                    scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                }
                .background(
                    GeometryReader {
                        Color.clear
                            .preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named(scrollNamespace)).origin.y
                            )
                    }
                )
                .onPreferenceChange(ViewOffsetKey.self) {
                    isScrollToFirst = $0 <= 0
                }
            }
        }
        .coordinateSpace(name: scrollNamespace)
    }

    private var chatBottomBar: some View {
        HStack(spacing: 12) {
            if isCollapseButton {
                BackButton {
                    isCollapseButton = false
                }
                .rotationEffect(.init(degrees: 180))
            } else {
                HStack(spacing: 4) {
                    Button {} label: {
                        ZStack {
                            Image("more")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.greenCustom)
                        }
                        .frame(width: 36, height: 36)
                    }
                    Button {
                        isShowCameraView.toggle()
                    } label: {
                        ZStack {
                            Image("camera")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23, height: 23)
                                .foregroundStyle(Color.greenCustom)
                        }
                        .frame(width: 36, height: 36)
                    }
                    Button {
                        isShowMediaPicker.toggle()
                    } label: {
                        ZStack {
                            Image("photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 21, height: 21)
                                .foregroundStyle(Color.greenCustom)
                        }
                        .frame(width: 36, height: 36)
                    }
                    Button {} label: {
                        ZStack {
                            Image("mic")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 21)
                                .foregroundStyle(Color.greenCustom)
                        }
                        .frame(width: 36, height: 36)
                    }
                }
            }

            ZStack {
                if viewModel.messageText.isEmpty || viewModel.isEmoji {
                    HStack {
                        Text("Aa")
                            .font(.body)
                            .foregroundStyle(Color.systemGray)
                        Spacer()
                    }
                    .padding(.leading, 4)
                }
                HStack {
//                    EmojiTextView(text: $viewModel.messageText, isEmoji: $viewModel.isEmoji)
                    TextEditor(text: $viewModel.messageText)
                        .scrollContentBackground(.hidden)
                        .padding(.top, 2)
                    Button {
                        viewModel.isEmoji.toggle()
                    } label: {
                        Image("emoji")
                            .foregroundStyle(Color.greenCustom)
                    }
                }
            }
            .padding(.horizontal, 8)
            .background(Color.systemGray5)
            .clipShape(Capsule())
            .frame(height: 40)

            Button {
                viewModel.sendMessageText()
            } label: {
                ZStack {
                    Image(viewModel.messageText.isEmpty ? "like" : "sent")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: viewModel.messageText.isEmpty ? 24 : 20,
                            height: viewModel.messageText.isEmpty ? 24 : 20
                        )
                        .foregroundStyle(Color.greenCustom)
                        .animation(.interactiveSpring(duration: 0.3), value: viewModel.messageText.isEmpty)
                }
                .frame(width: 36, height: 36)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isCollapseButton)
        .onChange(of: viewModel.messageText) { _ in
            isCollapseButton = true
        }
        .padding(.horizontal)
        .background(Color.systemBackground)
    }
}

struct InboxMessage: View {
    let message: Message

    @StateObject private var soundManager = SoundManager()

    var body: some View {
        VStack(spacing: 2) {
            if message.isFromCurrentUser {
                HStack {
                    Spacer()
                    messageContent
                        .clipShape(
                            .rect(
                                topLeadingRadius: 16,
                                bottomLeadingRadius: 16,
                                bottomTrailingRadius: 8,
                                topTrailingRadius: 16
                            )
                        )
                }
            } else {
                HStack(alignment: .bottom) {
                    LazyImageView(url: message.user?.profileImageUrl ?? "")
                        .scaledToFill()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                    messageContent
                        .clipShape(
                            .rect(
                                topLeadingRadius: 16,
                                bottomLeadingRadius: 8,
                                bottomTrailingRadius: 16,
                                topTrailingRadius: 16
                            )
                        )
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    var messageContent: some View {
        Group {
            if message.isImage ?? false {
                LazyImageView(url: message.messageText)
                    .scaledToFit()
                    .frame(height: 120)
            } else if message.isVideo ?? false, let url = URL(string: message.messageText) {
                VideoPlayer(player: AVPlayer(url: url))
                    .scaledToFit()
                    .frame(height: 200)
            } else if message.isAudio ?? false {
                Button {
                    Task {
                        try await playAudio()
                    }
                } label: {
                    Image(systemName: "play.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .scaledToFill()
                        .padding(.horizontal)
                }
            } else {
                Text(message.messageText)
                    .foregroundStyle(Color.label)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.systemGray5)
            }
        }
    }

    func playAudio() async throws {
        guard let audioURL = URL(string: message.messageText) else {
            print("Audio URL not found or invalid")
            return
        }

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent(audioURL.lastPathComponent)

        // Check if the file already exists locally
        if FileManager.default.fileExists(atPath: localURL.path) {
            // If the file exists locally, play it
            soundManager.playSound(sound: localURL.path)
        } else {
            // If the file doesn't exist locally, download it
            let downloadTask = URLSession.shared.downloadTask(with: audioURL) { tempURL, _, error in
                guard let tempURL = tempURL, error == nil else {
                    print("Error downloading audio: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                do {
                    // Move the downloaded file to the local URL
                    try FileManager.default.moveItem(at: tempURL, to: localURL)
                    // Play the downloaded audio file
                    DispatchQueue.main.async {
                        soundManager.playSound(sound: localURL.path)
                    }
                } catch {
                    print("Error moving file: \(error.localizedDescription)")
                }
            }
            downloadTask.resume()
        }
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Aa")
                .font(.body)
                .foregroundStyle(Color.systemGray)
            Spacer()
        }
    }
}

#Preview {
    RoutingView()
}
