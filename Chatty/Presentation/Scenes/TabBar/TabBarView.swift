//
//  TabBarView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 9/6/24.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject private var routingVM: RoutingViewModel

    var body: some View {
        TabView {
            NavigationStack {
                MainMessagesView()
            }
            .tabItem {
                Label(Tab.chats.rawValue, image: Tab.chats.image)
            }
            .tag(Tab.chats)

            NavigationStack {
                PeopleView()
            }
            .tabItem {
                Label(Tab.people.rawValue, image: Tab.people.image)
            }
            .tag(Tab.people)
        }
        .tint(Color.greenCustom)
    }
}

#Preview {
    TabBarView()
        .environmentObject(RoutingViewModel())
}

enum Tab: String {
    case chats = "Chats"
    case people = "People"

    var image: String {
        switch self {
        case .chats:
            "chats-tab"
        case .people:
            "people-tab"
        }
    }

    var index: Int {
        switch self {
        case .chats:
            0
        case .people:
            1
        }
    }
}
