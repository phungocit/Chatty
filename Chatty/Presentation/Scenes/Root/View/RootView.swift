//
//  RootView.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = RootViewModel()

    var body: some View {
        switch viewModel.authState {
        case .pending:
            LaunchView()
        case .loggedIn(let loggedInUser):
            MainTabView(loggedInUser)
        case .loggedOut:
            OnBoardingView()
        }
    }
}

#Preview {
    RootView()
}
