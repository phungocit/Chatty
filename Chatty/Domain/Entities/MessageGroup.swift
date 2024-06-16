//
//  MessageGroup.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Foundation

struct MessageGroup: Identifiable, Hashable {
    var id = UUID().uuidString
    let date: Date
    var messages: [Message]
}
