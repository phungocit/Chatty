//
//  BubbleAudioView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/15/24.
//

import AVFoundation
import SwiftUI

struct BubbleAudioView: View {
    @StateObject private var voiceMessagePlayer = VoiceMessagePlayer()
    @State private var sliderValue = 0.0
    private let item: MessageItem

    init(item: MessageItem) {
        self.item = item
        let thumbConfig = UIImage.SymbolConfiguration(scale: .small)
        UISlider.appearance()
            .setThumbImage(
                UIImage(systemName: "circle.fill", withConfiguration: thumbConfig), for: .normal
            )
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if item.showPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl, size: .xMini)
            }

            HStack {
                playButton
                Slider(value: $sliderValue, in: 0 ... (item.audioDuration ?? 1), onEditingChanged: sliderEditingChanged)
                    .tint(item.direction == .received ? Color(.label) : .white)

                if let duration = item.audioDuration, !duration.isNaN, !duration.isInfinite {
                    Text(formatter.string(from: duration) ?? "")
                        .font(.footnote)
                        .foregroundStyle(item.foregroundColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(item.backgroundColor)
            .applyTail(item.direction)
            .contextMenu {
                Button {} label: {
                    Label("ContextMenu", systemImage: "heart")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.trailingPadding)
        .onChange(of: voiceMessagePlayer.currentTime) { newValue in
            sliderValue = newValue.seconds
        }
    }

    private func sliderEditingChanged(editing: Bool) {
        if !editing {
            voiceMessagePlayer.seek(to: sliderValue)
        }
    }

    private var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }

    private var playButton: some View {
        Button {
            guard let audioURLString = item.audioURL, let url = URL(string: audioURLString) else { return }
            if voiceMessagePlayer.playbackState == .playing {
                voiceMessagePlayer.pauseAudio()
            } else {
                voiceMessagePlayer.playAudio(from: url)
            }
        } label: {
            Image(systemName: voiceMessagePlayer.playbackState == .playing ? "pause.fill" : "play.fill")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(item.direction == .received ? Color(.label) : .white)
        }
    }

    private var timeStampTextView: some View {
        Text(item.timeStamp.formatToTime)
            .font(.footnote)
            .foregroundStyle(.gray)
    }
}

#Preview {
    ScrollView {
        BubbleAudioView(item: .receivedPlaceholder)
        BubbleAudioView(item: .sentPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(Color.gray.opacity(0.4))
    .onAppear {
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
}
