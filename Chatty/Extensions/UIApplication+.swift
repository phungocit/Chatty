//
//  UIApplication+.swift
//  Chatty
//
//  Created by Tran Ngoc Phu on 8/6/24.
//

import Foundation
import UIKit

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
