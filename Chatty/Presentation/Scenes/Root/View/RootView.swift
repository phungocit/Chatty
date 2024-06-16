//
//  RootView.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = RootViewModel()
    @State private var isLaunchViewLoading = true

    var body: some View {
        if isLaunchViewLoading {
            LaunchView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isLaunchViewLoading = false
                    }
                }
        } else if viewModel.userSession != nil {
            TabBarView()
        } else {
            OnBoardingView()
        }
    }
}

#Preview {
    RootView()
}
