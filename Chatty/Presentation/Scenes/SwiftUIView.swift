//
//  SwiftUIView.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 11/6/24.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        NavigationStack {
            TabView {
                SubView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Contacts")
                    }

                SubView()
                    .tabItem {
                        Image(systemName: "phone")
                        Text("Calls")
                    }

                SubView()
                    .tabItem {
                        Image(systemName: "bubble.left")
                        Text("Chats")
                    }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SubView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(0 ..< 50) { i in
                        NavigationLink(destination: ChildView()) {
                            Text("Go to ChildView \(i)")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("asd")
                }
            }
        }
    }
}

struct ChildView: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0 ..< 50) { i in
                    Text("ChildView \(i)")
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SwiftUIView()
}
