//
//  Color+.swift
//  Chatty
//
//  Created by Phil Tran on 7/6/24.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
    // MARK: - ThemeColors
    static let greenCustom = Color("Green")

    static var random: Color {
        Color(red: .random(in: 0 ... 1), green: .random(in: 0 ... 1), blue: .random(in: 0 ... 1))
    }
}
