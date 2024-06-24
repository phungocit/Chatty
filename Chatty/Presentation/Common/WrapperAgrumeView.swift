//
//  WrapperAgrumeView.swift
//  Chatty
//
//  Created by Foo on 24/06/2024.
//

import Agrume
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
