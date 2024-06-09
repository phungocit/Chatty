//
//  BackButton.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 8/6/24.
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image("back")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color.greenCustom)
                .padding(4)
                .background(Color.clear)
        }
    }
}

#Preview {
    BackButton {}
}
