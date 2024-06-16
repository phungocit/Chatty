//
//  TabBarView.swift
//  Chatty
//
//  Created by Phil Tran on 9/6/24.
//

import SwiftUI

struct TabBarView: View {
    @StateObject private var profileViewModel = ProfileViewModel()

    var body: some View {
        TabView {
            ChatView()
                .environmentObject(profileViewModel)
                .tabItem {
                    Label(Tab.chats.rawValue, image: Tab.chats.image)
                }
                .tag(Tab.chats)

            PeopleView()
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
    TabBarView()
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
