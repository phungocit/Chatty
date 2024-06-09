//
//  OnBoardingView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 7/6/24.
//

import SwiftUI

struct OnBoardingView: View {
    @EnvironmentObject private var routingVM: RoutingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Connect friends")
                        .font(.system(size: 68))
                        .foregroundColor(Color.label)
                        + Text(" easily & quickly")
                        .font(.system(size: 68, weight: .bold))
                        .foregroundColor(Color.label)
                    Text("Our chat app is the perfect way to stay connected with friends and family.")
                        .font(.callout)
                        .foregroundStyle(Color.systemGray)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                VStack(spacing: 30) {
                    SocialAccountView()
                    HStack(spacing: 16) {
                        Rectangle()
                            .fill(Color.systemGray5)
                            .frame(height: 1)
                        Text("OR")
                            .font(.subheadline)
                            .foregroundStyle(Color.systemGray)
                        Rectangle()
                            .fill(Color.systemGray5)
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 6)
                    NavigationLink(value: RoutingPath.signUp) {
                        PrimaryButtonContentView(text: "Sign up with Email")
                    }
                }
                .padding(.top, 20)
                HStack(spacing: 0) {
                    Text("Existing account?")
                        .foregroundStyle(Color.systemGray)
                        .font(.callout)
                    NavigationLink(value: RoutingPath.logIn) {
                        Text(" Log in")
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.greenCustom)
                    }
                }
                .padding(.top, 36)
                .padding(.bottom)
            }
            .padding(.top)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color.systemBackground)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Image("logo-before")
                        .resizable()
                        .frame(width: 16, height: 19)
                    Text("Chatty")
                        .font(.callout)
                        .fontWeight(.medium)
                }
                .foregroundStyle(Color.label)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationPath(routingVM)
    }
}

#Preview {
    NavigationStack {
        OnBoardingView()
            .environmentObject(RoutingViewModel())
    }
}
