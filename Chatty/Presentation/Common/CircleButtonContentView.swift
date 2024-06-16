//
//  CircleButtonContentView.swift
//  Chatty
//
//  Created by Phil Tran on 8/6/24.
//

import SwiftUI

struct CircleButtonContentView: View {
    private let backgroundColor: Color
    private let imageColor: Color
    private let imageName: String

    init(imageName: String, imageColor: Color = Color.label, backgroundColor: Color = Color.systemGray5) {
        self.imageName = imageName
        self.backgroundColor = backgroundColor
        self.imageColor = imageColor
    }

    var body: some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: 40, height: 40)
            .overlay {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(imageColor)
            }
    }
}

#Preview {
    VStack {
        CircleButtonContentView(imageName: "camera")
            .scaleEffect(.init(width: 2, height: 2))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
