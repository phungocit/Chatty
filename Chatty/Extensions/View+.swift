//
//  View+.swift
//  Chatty
//
//  Created by Phil Tran on 8/6/24.
//

import SwiftUI

extension View {
    func dismissKeyboard() -> some View {
        onTapGesture {
            UIApplication.dismissKeyboard()
        }
    }

    func applyTail(_ direction: MessageDirection) -> some View {
        clipShape(
            .rect(
                topLeadingRadius: 16,
                bottomLeadingRadius: direction == .received ? 8 : 16,
                bottomTrailingRadius: direction == .sent ? 8 : 16,
                topTrailingRadius: 16
            )
        )
    }
}
