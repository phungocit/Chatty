//
//  RoutingView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 8/6/24.
//

import SwiftUI

struct RoutingView: View {
    @StateObject private var routingVM = RoutingViewModel()
    @State private var isLaunchViewLoading = true

    var body: some View {
        if isLaunchViewLoading {
            LaunchView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isLaunchViewLoading = false
                    }
                }
        } else {
            Group {
                if routingVM.isLoggedIn {
                    TabBarView()
                } else {
                    OnBoardingView()
                }
            }
            .environmentObject(routingVM)
        }
    }
}

#Preview {
    RoutingView()
}
