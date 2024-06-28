//
//  ClosePreviewButton.swift
//  Chatty
//
//  Created by Phil Tran on 24/06/2024.
//

import SwiftUI

struct ClosePreviewButton: View {
    let dismissPlayer: () -> Void

    var body: some View {
        Button {
            dismissPlayer()
        } label: {
            Image(systemName: "xmark")
                .scaledToFit()
                .imageScale(.medium)
                .padding(8)
                .foregroundStyle(.white)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(radius: 5)
                .bold()
        }
        .padding()
    }
}

#Preview {
    ClosePreviewButton {}
}
