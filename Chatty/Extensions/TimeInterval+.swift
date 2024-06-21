//
//  TimeInterval+.swift
//  Chatty
//
//  Created by Foo on 21/06/2024.
//

import Foundation

extension TimeInterval {
    var formatElapsedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    static var stubTimeInterval: TimeInterval {
        TimeInterval()
    }
}