//
//  ChatView.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @StateObject private var viewModel = ChatViewModel()
    @State private var isShowProfileView = false
    @State private var isShowNewMessageView = false
    @State private var isPushToInboxView = false
    @State private var isShowDeleteConfirmAlert = false
    @State private var selectedUser: User?
    @State private var chatIdDelete: String?

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.latestMessages, id: \.id) { message in
                    Button {
                        if let user = message.user {
                            print(message.id)
                            selectedUser = user
                            isPushToInboxView.toggle()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            LazyImageView(url: message.user?.profileImageUrl ?? "")
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(message.user?.fullName ?? "")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(.label))
                                    .lineLimit(1)
                                Text(message.displayContent)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .foregroundStyle(Color(.systemGray))
                            }
                            Spacer()
                            Text(message.timestampString)
                                .font(.footnote)
                                .lineLimit(1)
                                .foregroundColor(Color(.systemGray))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .id(message.id)
                    .buttonStyle(.plain)
                    .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .swipeActions(allowsFullSwipe: false) {
                        Button {
                            chatIdDelete = message.id
                            isShowDeleteConfirmAlert = true
                            //                            Task {
                            //                                await viewModel.deleteChat(chatId: message.id)
                            //                            }
                        } label: {
                            swipeIcon(label: "Delete", imageName: "trash")
                        }
                        .tint(Color(.systemRed))
                    }
                }
            }
            .listStyle(.plain)
            .background(Color(.systemBackground))
            .padding(.top, -12)
            .overlay {
                if viewModel.isShowLoading {
                    ProgressView()
                        .tint(Color(.systemGray))
                }
            }
            .searchable(text: .constant(""), prompt: "Search")
            .toolbar(.visible, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if profileViewModel.user != nil {
                            isShowProfileView.toggle()
                        }
                    } label: {
                        LazyImageView(url: profileViewModel.user?.profileImageUrl ?? "")
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Chats")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.label))
                }
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isPushToInboxView) {
                if let selectedUser {
                    InboxView(user: selectedUser)
                }
            }
            .fullScreenCover(
                isPresented: $isShowProfileView,
                content: {
                    if let user = profileViewModel.user {
                        ProfileView(user: user)
                    }
                }
            )
            .sheet(isPresented: $isShowNewMessageView) {
                NewMessage { user in
                    selectedUser = user
                    isPushToInboxView.toggle()
                }
            }
            .alert("Delete this conversation?", isPresented: $isShowDeleteConfirmAlert) {
                Button("Delete", role: .destructive) {
                    if let chatIdDelete {
                        Task {
                            await viewModel.deleteChat(chatId: chatIdDelete)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {
                    chatIdDelete = nil
                }
            } message: {
                Text("Everything in this conversation will be permanently deleted.")
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
    RootView()
        .onAppear {
            //            AuthService.shared.signOut()
        }
}
