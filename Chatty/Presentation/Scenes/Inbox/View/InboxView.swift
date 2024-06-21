//
//  InboxView.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Agrume
import AVKit
import SwiftUI

struct WrapperAgrumeView: UIViewControllerRepresentable {
    let url: URL
    let willDismiss: (() -> Void)?

    func makeUIViewController(context: Context) -> UIViewController {
        let agrume = Agrume(
            url: url,
            background: .blurred(.systemUltraThinMaterial),
            dismissal: .withPan(.init(permittedDirections: .verticalOnly, allowsRotation: false))
        )
        agrume.addSubviews()
        agrume.addOverlayView()
        agrume.willDismiss = willDismiss
        return agrume
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct InboxView: View {
    @StateObject var viewModel: InboxViewModel

    @StateObject private var soundManager = SoundManager()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @State private var isShowMediaPicker = false
    @State private var isShowCameraView = false
    @State private var isShowVideoPicker = false
    @State private var isScrollToFirst = false
    @State private var isCollapseButton = false
    @State private var tabBarVisibility = Visibility.hidden
    @State private var selectedMessage: Message?
    @State private var selectedPlayer = AVPlayer()
    @State private var isFullScreen = false

    private let scrollNamespace = "scroll"

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let emptyScrollToString = "Empty"

    init(user: User) {
        _viewModel = .init(wrappedValue: .init(user: user))
    }

    var body: some View {
        messagesView
            .fullScreenCover(isPresented: $isFullScreen) {
                ZStack {
                    VideoPlayer(player: selectedPlayer)
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .topTrailing) {
                    Button {
                        isFullScreen = false
                    } label: {
                        ZStack {
                            Image("close")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(Color.label)
                        }
                        .frame(width: 32, height: 32)
                        .padding()
                    }
                }
            }
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
            .toolbar(selectedMessage != nil ? .hidden : .visible, for: .navigationBar)
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
            .overlay {
                if let selectedMessage, let url = URL(string: selectedMessage.messageText) {
                    WrapperAgrumeView(url: url) {
                        self.selectedMessage = nil
                    }
                    .ignoresSafeArea()
                    .overlay(alignment: .topTrailing) {
                        Button {
                            self.selectedMessage = nil
                        } label: {
                            ZStack {
                                Image("close")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(Color.label)
                            }
                            .frame(width: 32, height: 32)
                            .padding()
                        }
                    }
                }
            }
    }

    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                LazyVStack {
                    ForEach(viewModel.messageGroups) { group in
                        Section {
                            ForEach(group.messages) { message in
                                inboxMessage(message)
                                    .id(message.id)
                            }
                        } header: {
                            Text(group.date.chatTimestampString())
                                .font(.footnote)
                                .foregroundStyle(Color.label)
                        }
                        .id(group.id)
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
            HStack(spacing: 4) {
                if !isCollapseButton {
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
                            // isShowCameraView.toggle()
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
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: isCollapseButton ? .trailing : .leading),
                            removal: .move(edge: isCollapseButton ? .trailing : .leading)
                        )
                    )
                }
                Button {
                    if isCollapseButton {
                        withAnimation {
                            isCollapseButton = false
                        }
                    } else {
                        // mic action
                    }
                } label: {
                    ZStack {
                        Image(isCollapseButton ? "collapse" : "mic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: isCollapseButton ? 9 : 22, height: isCollapseButton ? 16 : 21)
                            .foregroundStyle(Color.greenCustom)
                    }
                    .frame(width: isCollapseButton ? 22 : 36, height: isCollapseButton ? 22 : 36)
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
                        .focused($isFocused)
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
                        .animation(.interactiveSpring(duration: 0.25), value: viewModel.messageText.isEmpty)
                }
                .frame(width: 36, height: 36)
            }
        }
        .onChange(of: isFocused) { newValue in
            withAnimation {
                isCollapseButton = newValue
            }
        }
        .onChange(of: viewModel.messageText) { _ in
            if !isCollapseButton, isFocused {
                withAnimation {
                    isCollapseButton = true
                }
            }
        }
        .padding(.horizontal)
        .background(Color.systemBackground)
    }

    func inboxMessage(_ message: Message) -> some View {
        VStack(spacing: 2) {
            if message.isFromCurrentUser {
                HStack {
                    Spacer()
                    messageContent(message)
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
                    messageContent(message)
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

    func messageContent(_ message: Message) -> some View {
        Group {
            if message.isImage ?? false {
                LazyImageView(url: message.messageText)
                    .scaledToFit()
                    .frame(maxWidth: 250)
                    .onTapGesture {
                        selectedMessage = message
                    }
            } else if message.isVideo ?? false, let url = URL(string: message.messageText) {
                let aaa = AVPlayer(url: url)
                VideoPlayer(player: aaa) {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .padding(16)
                                .foregroundStyle(.white)
                                .onTapGesture {
                                    selectedPlayer = aaa
                                    isFullScreen = true
                                }
                        }
                        Spacer()
                    }
                }
                .scaledToFit()
                .frame(maxWidth: 250)
            } else if message.isAudio ?? false {
                Button {
                    Task {
                        try await playAudio(url: message.messageText)
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

    func playAudio(url: String) async throws {
        guard let audioURL = URL(string: url) else {
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
    RootView()
}
