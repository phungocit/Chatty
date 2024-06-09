//
//  TabBarView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 9/6/24.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject private var routingVM: RoutingViewModel
    @State var selection = Tab.chats

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack(path: $routingVM.mainMessagePath) {
                MainMessagesView()
//                    .toolbar(.visible, for: .tabBar)
            }
            .tabItem {
                Label(Tab.chats.rawValue, image: Tab.chats.image)
            }
            .tag(Tab.chats)
            NavigationStack(path: $routingVM.mainMessagePath) {
                PeopleView()
            }
            .tabItem {
                Label(Tab.people.rawValue, image: Tab.people.image)
                    .foregroundStyle(Color.label)
            }
            .tag(Tab.people)
        }
        .tint(Color.label)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selection)
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
}
