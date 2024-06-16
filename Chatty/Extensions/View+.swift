//
//  View+.swift
//  Chatty
//
//  Created by Phil Tran on 8/6/24.
//

import SwiftUI

extension View {
    func navigationPath(_ routingVM: RoutingViewModel) -> some View {
        navigationDestination(for: RoutingPath.self) { destination in
            Group {
                switch destination {
                case .onBoarding:
                    OnBoardingView()
                case .signUp:
                    SignUpView()
                case .logIn:
                    SignInView()
                case .mainMessage:
                    MainMessagesView()
                }
            }
            .environmentObject(routingVM)
        }
    }

    func dismissKeyboard() -> some View {
        onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
    }
}
