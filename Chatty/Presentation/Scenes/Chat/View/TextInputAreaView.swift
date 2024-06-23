//
//  TextInputAreaView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 22/6/24.
//

import SwiftUI

struct TextInputAreaView: View {
    @Binding var textMessage: String
    @Binding var isRecording: Bool
    @Binding var elapsedTime: TimeInterval
    var isShowLikeButton: Bool
    let actionHandler: (_ action: UserAction) -> Void

    @FocusState private var isFocused: Bool
    @State private var isPulsing = false
    @State private var isCollapseButton = false

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                if !isCollapseButton {
                    HStack(spacing: 4) {
                        moreButton
                        cameraButton
                        mediaPickerButton
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: isCollapseButton ? .trailing : .leading),
                            removal: .move(edge: isCollapseButton ? .trailing : .leading)
                        )
                    )
                }
                audioRecorderButton
            }

            Group {
                if isRecording {
                    audioSessionIndicatorView
                } else {
                    messageTextField
                }
            }
            .padding(.horizontal, 8)
            .background(Color(.systemGray5))
            .clipShape(Capsule())
            .frame(height: 40)

            sendMessageButton
        }
        .onChange(of: isFocused) { newValue in
            withAnimation {
                isCollapseButton = newValue
            }
        }
        .onChange(of: textMessage) { _ in
            if !isCollapseButton, isFocused {
                withAnimation {
                    isCollapseButton = true
                }
            }
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
        .animation(.spring, value: isRecording)
        .onChange(of: isRecording) { isRecording in
            if isRecording {
                withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }

    private var audioSessionIndicatorView: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundStyle(.red)
                .font(.caption)
                .scaleEffect(isPulsing ? 1.8 : 1.0)

            Text("Recording audio")
                .font(.callout)
                .lineLimit(1)

            Spacer()

            Text(elapsedTime.formatElapsedTime)
                .font(.callout)
                .fontWeight(.semibold)
        }
    }

    private var messageTextField: some View {
        ZStack {
            if textMessage.isEmpty {
                HStack {
                    Text("Aa")
                        .font(.body)
                        .foregroundStyle(Color(.systemGray))
                    Spacer()
                }
                .padding(.leading, 4)
            }
            HStack {
                TextEditor(text: $textMessage)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .padding(.top, 2)
                Button {
                    actionHandler(.showEmoji)
                } label: {
                    Image("emoji")
                        .foregroundStyle(Color.greenCustom)
                }
            }
        }
    }

    private var cameraButton: some View {
        Button {
            actionHandler(.presentCamera)
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
    }

    private var mediaPickerButton: some View {
        Button {
            actionHandler(.presentMediaPicker)
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
        .disabled(isRecording)
        .grayscale(isRecording ? 0.8 : 0)
    }

    private var audioRecorderButton: some View {
        Button {
            if !isCollapseButton || isRecording {
                actionHandler(.recordAudio)
            }
            withAnimation {
                isCollapseButton.toggle()
            }
        } label: {
            ZStack {
                Image(isCollapseButton ? "collapse" : isRecording ? "pause" : "mic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isCollapseButton ? 9 : 22, height: isCollapseButton ? 16 : 21)
                    .foregroundStyle(isRecording ? Color.white : Color.greenCustom)
            }
            .frame(width: isCollapseButton ? 22 : 36, height: isCollapseButton ? 22 : 36)
        }
    }

    private var sendMessageButton: some View {
        Button {
            actionHandler(.sendMessage)
        } label: {
            ZStack {
                Image(isShowLikeButton ? "like" : "sent")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: textMessage.isEmpty ? 24 : 20,
                        height: textMessage.isEmpty ? 24 : 20
                    )
                    .foregroundStyle(Color.greenCustom)
                    .animation(.interactiveSpring(duration: 0.25), value: textMessage.isEmpty)
            }
            .frame(width: 36, height: 36)
        }
        .disabled(isRecording)
    }

    private var moreButton: some View {
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
    }
}

extension TextInputAreaView {
    enum UserAction {
        case presentCamera
        case presentMediaPicker
        case sendMessage
        case recordAudio
        case showEmoji
    }
}

#Preview {
    TextInputAreaView(textMessage: .constant(""), isRecording: .constant(false), elapsedTime: .constant(0), isShowLikeButton: false) { _ in }
}
