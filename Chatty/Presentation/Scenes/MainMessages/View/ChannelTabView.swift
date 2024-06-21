//
//  ChannelTabView.swift
//  Chatty
//
//  Created by Foo on 21/06/2024.
//

import SwiftUI

struct ChannelTabView: View {
    @StateObject private var viewModel: ChannelTabViewModel
    @State private var isShowProfileView = false
    @State private var isShowNewMessageView = false
    @State private var isShowDeleteConfirmAlert = false
    @State private var currentUser: UserItem

    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        _viewModel = StateObject(wrappedValue: ChannelTabViewModel(currentUser))
    }

    var body: some View {
        NavigationStack(path: $viewModel.navRoutes) {
            List {
                ForEach(viewModel.channels, id: \.id) { channel in
                    Button {
                        viewModel.navRoutes.append(.chatRoom(channel))
                    } label: {
                        ChannelItemView(channel: channel)
                    }
                    .id(channel.id)
                    .buttonStyle(.plain)
                    .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .swipeActions(allowsFullSwipe: false) {
                        Button {
                            isShowDeleteConfirmAlert = true
                        } label: {
                            swipeIcon(label: "Delete", imageName: "trash")
                        }
                        .tint(Color.systemRed)
                    }
                }
            }
            .listStyle(.plain)
            .background(Color.systemBackground)
            .padding(.top, -12)
            .overlay {
                //                if viewModel.isShowLoading {
                //                    ProgressView()
                //                        .tint(Color.systemGray)
                //                }
            }
            .searchable(text: .constant(""), prompt: "Search")
            .toolbar(.visible, for: .tabBar)
            .toolbar {
                leadingNavItem
                principalNavItem
                trailingNavItem
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ChannelTabRoutes.self) { route in
                destinationView(for: route)
            }
            .fullScreenCover(
                isPresented: $isShowProfileView,
                content: {
                    ProfileView(user: .init(uid: currentUser.uid, fullName: currentUser.username, email: currentUser.email, profileImageUrl: currentUser.profileImageUrl))
                }
            )
            .sheet(isPresented: $isShowNewMessageView) {
//                ChatPartnerPickerView(onCreate: viewModel.onNewChannelCreation)
            }
            .alert("Delete this conversation?", isPresented: $isShowDeleteConfirmAlert) {
                Button("Delete", role: .destructive) {}
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Everything in this conversation will be permanently deleted.")
            }
        }
    }
}

extension ChannelTabView {
    @ViewBuilder
    private func destinationView(for route: ChannelTabRoutes) -> some View {
//        switch route {
//        case .chatRoom(let channel):
//            ChatRoomView(channel: channel)
//        }
    }

    @ToolbarContentBuilder
    private var leadingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                isShowProfileView.toggle()
            } label: {
                CircularProfileImageView(currentUser.profileImageUrl, size: .mini)
            }
        }
    }

    @ToolbarContentBuilder
    private var principalNavItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Chats")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.label)
        }
    }

    @ToolbarContentBuilder
    private var trailingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isShowNewMessageView.toggle()
            } label: {
                Image("new-message")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.greenCustom)
            }
        }
    }

    private func swipeIcon(label: String, imageName: String) -> some View {
        let w: CGFloat = 60
        let h = w
        let size = CGSize(width: w, height: h)
        let text = Text(LocalizedStringKey(label))
            .font(.footnote)
        let symbol = Image(imageName)
        return Image(size: size, label: text) { ctx in
            let resolvedText = ctx.resolve(text)
            let textSize = resolvedText.measure(in: CGSize(width: w, height: h * 0.6))
            let resolvedSymbol = ctx.resolve(symbol)
            let symbolSize = resolvedSymbol.size
            let heightForSymbol: CGFloat = min(h * 0.35, (h * 0.9) - textSize.height)
            let widthForSymbol = (heightForSymbol / symbolSize.height) * symbolSize.width
            let xSymbol = (w - widthForSymbol) / 2
            let ySymbol = max(h * 0.05, heightForSymbol - (textSize.height * 0.6))
            let yText = ySymbol + heightForSymbol + max(0, ((h * 0.8) - heightForSymbol - textSize.height) / 2)
            let xText = (w - textSize.width) / 2
            ctx.draw(
                resolvedSymbol,
                in: CGRect(x: xSymbol, y: ySymbol, width: widthForSymbol, height: heightForSymbol)
            )
            ctx.draw(
                resolvedText,
                in: CGRect(x: xText, y: yText, width: textSize.width, height: textSize.height)
            )
        }
        .foregroundStyle(.white)
        .lineLimit(2)
        .lineSpacing(-2)
        .minimumScaleFactor(0.7)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    ChannelTabView(.placeholder)
}
