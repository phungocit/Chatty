//
//  UIWindowScene+.swift
//  Chatty
//
//  Created by Phil Tran on 21/06/2024.
//

import UIKit

extension UIWindowScene {
    static var current: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .first { $0 is UIWindowScene } as? UIWindowScene
    }

    var screenHeight: CGFloat {
        UIWindowScene.current?.screen.bounds.height ?? 0
    }

    var screenWidth: CGFloat {
        UIWindowScene.current?.screen.bounds.width ?? 0
    }
}
