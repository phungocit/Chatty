//
//  String+.swift
//  Chatty
//
//  Created by Phil Tran on 8/6/24.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        if count > 50 {
            return false
        }
        let regex = try?
            NSRegularExpression(
                pattern: "^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$",
                options: .caseInsensitive
            )
        return regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }

    var isEmptyOrWhiteSpace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
