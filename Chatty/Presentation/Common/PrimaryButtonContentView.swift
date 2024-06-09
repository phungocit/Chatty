//
//  PrimaryButtonContentView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 7/6/24.
//

import SwiftUI

struct PrimaryButtonContentView: View {
    private let isEnable: Bool
    private let text: String

    init(isEnable: Bool = true, text: String) {
        self.isEnable = isEnable
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundStyle(isEnable ? Color.white : Color.systemGray)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(isEnable ? Color.greenCustom : Color.systemGray5)
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
    }
}

#Preview {
    VStack {
        PrimaryButtonContentView(isEnable: false, text: "Disable")
        PrimaryButtonContentView(text: "Enable")
    }
}
