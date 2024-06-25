//
//  WrapperAgrumeView.swift
//  Chatty
//
//  Created by Foo on 24/06/2024.
//

import Agrume
import SwiftUI

struct WrapperAgrumeView: UIViewControllerRepresentable {
    let thumbnail: PhotoPreview
    let willDismiss: (() -> Void)?

    private let background = Background.blurred(.systemUltraThinMaterial)
    private let dismissal = Dismissal.withPan(.init(permittedDirections: .verticalOnly, allowsRotation: false))

    func makeUIViewController(context: Context) -> UIViewController {
        var agrume: Agrume?

        if let image = thumbnail.localPhoto {
            agrume = Agrume(image: image, background: background, dismissal: dismissal)
        } else if let url = thumbnail.remotePhoto {
            agrume = Agrume(url: url, background: background, dismissal: dismissal)
        }

        agrume?.addSubviews()
        agrume?.addOverlayView()
        agrume?.willDismiss = willDismiss

        return agrume ?? UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
