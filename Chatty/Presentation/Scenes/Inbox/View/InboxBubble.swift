//
//  InboxBubble.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import SwiftUI

struct InboxBubble: Shape {
    let isFromCurrentUser: Bool

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isFromCurrentUser ? .bottomLeft : .bottomRight,
            ],
            cornerRadii: CGSize(width: 8, height: 8)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    InboxBubble(isFromCurrentUser: true)
}
