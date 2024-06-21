//
//  View+.swift
//  Chatty
//
//  Created by Phil Tran on 8/6/24.
//

import SwiftUI

extension View {
    func dismissKeyboard() -> some View {
        onTapGesture {
            UIApplication.dismissKeyboard()
        }
    }
}
