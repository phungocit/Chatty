//
//  SocialAccountView.swift
//  Chatty
//
//  Created by Phil Tran on 8/6/24.
//

import SwiftUI

struct SocialAccountView: View {
    var body: some View {
        HStack(spacing: 20) {
            Button {
                UIApplication.shared.dismissKeyboard()
            } label: {
                Circle()
                    .strokeBorder(Color.systemGray)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image("facebook")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
            }

            Button {
                UIApplication.shared.dismissKeyboard()
            } label: {
                Circle()
                    .strokeBorder(Color.systemGray)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
            }
            Button {
                UIApplication.shared.dismissKeyboard()
            } label: {
                Circle()
                    .strokeBorder(Color.systemGray)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image("apple")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.label)
                    }
            }
        }
    }
}

#Preview {
    SocialAccountView()
}
