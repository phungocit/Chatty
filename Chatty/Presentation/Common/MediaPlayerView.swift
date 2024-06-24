//
//  MediaPlayerView.swift
//  Chatty
//
//  Created by Foo on 21/06/2024.
//

import AVKit
import SwiftUI

struct MediaPlayerView: View {
    let player: AVPlayer
    let dismissPlayer: () -> Void

    var body: some View {
        VideoPlayer(player: player)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                ClosePreviewButton(dismissPlayer: dismissPlayer)
            }
            .onAppear {
                player.play()
            }
    }
}
