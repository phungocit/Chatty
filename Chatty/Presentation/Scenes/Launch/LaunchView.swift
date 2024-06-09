//
//  LaunchView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 8/6/24.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                Image("logo-after")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 71)
                    .foregroundStyle(Color.black)
                Image("logo-before")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .foregroundStyle(Color.white)
            }
            Text("Chatty")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greenCustom)
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LaunchView()
}
