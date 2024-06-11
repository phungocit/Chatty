//
//  TabBarView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 9/6/24.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject private var routingVM: RoutingViewModel
    @State var selectedTab = Tab.chats
    @State var selectedTab1 = Tab.chats
    @State var search = true
    let messageView = MainMessagesView()
    let peopleView = PeopleView()

    var body: some View {
        //        UITabView(selection: $selectedTab) {
        //            NavigationStack(path: $routingVM.mainMessagePath) {
        //                MainMessagesView()
        //            }
        //            .tabItem(Tab.chats.rawValue, image: UIImage(named: Tab.chats.image))
        //
        //            NavigationStack(path: $routingVM.mainMessagePath) {
        //                PeopleView()
        //            }
        //            .tabItem(Tab.people.rawValue, image: UIImage(named: Tab.people.image))
//        NavigationStack(path: $routingVM.mainMessagePath) {
//            ZStack(alignment: .topLeading) {
//                switch selectedTab1 {
//                case .chats:
//                    messageView
//                        .onAppear {
//                            print("messageView")
//                        }
//                case .people:
//                    peopleView
//                        .onAppear {
//                            print("peopleView")
//                        }
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//            .toolbar {
//                ToolbarItem(placement: .bottomBar) {
//                    HStack {
//                        VStack {
//                            Image(Tab.chats.image)
//                            Text(Tab.chats.rawValue)
//                                .font(.caption2)
//                        }
//                        .foregroundStyle(selectedTab1 == .chats ? Color.greenCustom : Color.systemGray2)
//                        .frame(minWidth: 0, maxWidth: .infinity)
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            selectedTab1 = .chats
//                        }
//
//                        VStack {
//                            Image(Tab.people.image)
//                            Text(Tab.people.rawValue)
//                                .font(.caption2)
//                        }
//                        .foregroundStyle(selectedTab1 == .people ? Color.greenCustom : Color.systemGray2)
//                        .frame(minWidth: 0, maxWidth: .infinity)
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            selectedTab1 = .people
//                        }
//                    }
//                }
//            }
//        }
        NavigationStack(path: $routingVM.mainMessagePath) {
            TabView(selection: $selectedTab) {
                NavigationStack(path: $routingVM.mainMessagePath) {
                    MainMessagesView()
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
                }
                .tag(Tab.people)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // shouldShowLogOutOptions.toggle()
                    } label: {
                        LazyImageView(url: "https://images.pexels.com/photos/96938/pexels-photo-96938.jpeg?cs=srgb&dl=pexels-francesco-ungaro-96938.jpg&fm=jpg")
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(selectedTab == .chats ? "Chats" : "People")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.label)
                }
                if selectedTab == .chats {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            // shouldShowNewMessageScreen.toggle()
                        } label: {
                            Image("new-message")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.greenCustom)
                        }
                    }
                }
            }
            .toolbar(.visible, for: .navigationBar)
            .toolbarBackground(.white, for: .navigationBar)
            .onChange(of: selectedTab) { newValue in
                search = newValue == .chats
            }
            .tint(Color.greenCustom)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
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

// https://gist.github.com/Amzd/2eb5b941865e8c5cccf149e6e07c8810

private struct UITabView: View {
    private let viewControllers: [UIHostingController<AnyView>]
    private let tabBarItems: [TabBarItem]
    @Binding private var selectedIndex: Int

    init(selection: Binding<Int>, @TabBuilder _ content: () -> [TabBarItem]) {
        _selectedIndex = selection

        (viewControllers, tabBarItems) = content().reduce(into: ([], [])) { result, next in
            let tabController = UIHostingController(rootView: next.view)
            tabController.tabBarItem = next.barItem
            result.0.append(tabController)
            result.1.append(next)
        }
    }

    var body: some View {
        TabBarController(
            controllers: viewControllers,
            tabBarItems: tabBarItems,
            selectedIndex: $selectedIndex
        )
        .ignoresSafeArea()
    }
}

private extension UITabView {
    struct TabBarItem {
        let view: AnyView
        let barItem: UITabBarItem
        let badgeValue: String?

        init<T>(
            title: String,
            image: UIImage?,
            selectedImage: UIImage? = nil,
            badgeValue: String? = nil,
            content: T
        ) where T: View {
            view = AnyView(content)
            barItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
            self.badgeValue = badgeValue
        }
    }

    struct TabBarController: UIViewControllerRepresentable {
        let controllers: [UIViewController]
        let tabBarItems: [TabBarItem]
        @Binding var selectedIndex: Int

        func makeUIViewController(context: Context) -> UITabBarController {
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = controllers
            tabBarController.delegate = context.coordinator
            tabBarController.selectedIndex = selectedIndex
            return tabBarController
        }

        func updateUIViewController(_ tabBarController: UITabBarController, context: Context) {
            tabBarController.selectedIndex = selectedIndex

            tabBarItems.forEach { tab in
                guard let index = tabBarItems.firstIndex(where: { $0.barItem == tab.barItem }),
                      let controllers = tabBarController.viewControllers
                else {
                    return
                }

                guard controllers.indices.contains(index) else { return }
                controllers[index].tabBarItem.badgeValue = tab.badgeValue
            }
        }

        func makeCoordinator() -> TabBarCoordinator {
            TabBarCoordinator(self)
        }
    }

    class TabBarCoordinator: NSObject, UITabBarControllerDelegate {
        private static let inlineTitleRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        private var parent: TabBarController

        init(_ tabBarController: TabBarController) {
            parent = tabBarController
        }

        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            guard parent.selectedIndex == tabBarController.selectedIndex else {
                parent.selectedIndex = tabBarController.selectedIndex
                return
            }

            guard let navigationController = navigationController(in: viewController) else {
                scrollToTop(in: viewController)
                return
            }

            guard navigationController.visibleViewController == navigationController.viewControllers.first else {
                navigationController.popToRootViewController(animated: true)
                return
            }

            scrollToTop(in: navigationController, selectedIndex: tabBarController.selectedIndex)
        }

        func scrollToTop(in navigationController: UINavigationController, selectedIndex: Int) {
            let views = navigationController.viewControllers
                .map(\.view.subviews)
                .reduce([], +) // swiftlint:disable:this reduce_into

            guard let scrollView = scrollView(in: views) else { return }
            scrollView.scrollRectToVisible(Self.inlineTitleRect, animated: true)
        }

        func scrollToTop(in viewController: UIViewController) {
            let views = viewController.view.subviews

            guard let scrollView = scrollView(in: views) else { return }
            scrollView.scrollRectToVisible(Self.inlineTitleRect, animated: true)
        }

        func scrollView(in views: [UIView]) -> UIScrollView? {
            var view: UIScrollView?

            views.forEach {
                guard let scrollView = $0 as? UIScrollView else {
                    view = scrollView(in: $0.subviews)
                    return
                }

                view = scrollView
            }

            return view
        }

        func navigationController(in viewController: UIViewController) -> UINavigationController? {
            var controller: UINavigationController?

            if let navigationController = viewController as? UINavigationController {
                return navigationController
            }

            viewController.children.forEach {
                guard let navigationController = $0 as? UINavigationController else {
                    controller = navigationController(in: $0)
                    return
                }

                controller = navigationController
            }

            return controller
        }
    }
}

private extension View {
    func tabItem(
        _ title: String,
        image: UIImage?,
        selectedImage: UIImage? = nil,
        badgeValue: String? = nil
    ) -> UITabView.TabBarItem {
        UITabView.TabBarItem(
            title: title,
            image: image,
            selectedImage: selectedImage,
            badgeValue: badgeValue,
            content: self
        )
    }
}

@resultBuilder
private enum TabBuilder {
    static func buildBlock(_ elements: UITabView.TabBarItem...) -> [UITabView.TabBarItem] {
        elements
    }
}
