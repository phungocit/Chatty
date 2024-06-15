//
//  LazyImageView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 8/6/24.
//

import NukeUI
import SwiftUI

struct LazyImageView<Content: View>: View {
    private let urlString: String?
    private var content: ((LazyImageState) -> Content)?

    init(url urlString: String?) where Content == Image {
        self.urlString = urlString
    }

    init(url urlString: String?, @ViewBuilder content: @escaping (LazyImageState) -> Content) {
        self.urlString = urlString
        self.content = content
    }

    var body: some View {
        let url = URL(string: urlString ?? "")

        if let content {
            LazyImage(url: url, content: content)
        } else {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                } else {
                    Color.systemGray6
                    // Color.random
                        .overlay {
                            // ProgressView()
                        }
                }
            }
        }
    }
}

#Preview {
    // swiftlint:disable:next line_length
    LazyImageView(url: "https://images.pexels.com/photos/96938/pexels-photo-96938.jpeg?cs=srgb&dl=pexels-francesco-ungaro-96938.jpg&fm=jpg")
        .scaledToFit()
}
