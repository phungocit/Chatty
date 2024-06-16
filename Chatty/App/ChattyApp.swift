//
//  ChattyApp.swift
//  Chatty
//
//  Created by Phil Tran on 10/23/21.
//

import Firebase
import SwiftUI

@main
struct ChattyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
