//
//  MainTabView.swift
//  Chatty
//
//  Created by Phil Tran on 9/6/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var profileViewModel = ProfileViewModel()

    private let currentUser: UserItem

    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
    }

    var body: some View {
        TabView {
            ChannelTabView(currentUser)
                .environmentObject(profileViewModel)
                .tabItem {
                    Label(Tab.chats.rawValue, image: Tab.chats.image)
                }
                .tag(Tab.chats)

            PeopleView(currentUser)
                .environmentObject(profileViewModel)
                .tabItem {
                    Label(Tab.people.rawValue, image: Tab.people.image)
                }
                .tag(Tab.people)
        }
        .tint(Color.greenCustom)
    }
}

#Preview {
    MainTabView(.placeholder)
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
