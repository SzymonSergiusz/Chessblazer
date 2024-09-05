//
//  Settings.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 02/08/2024.
//

import Foundation
import SwiftUI

class Settings {
    static let lightBrown = Color(red: 245 / 255, green: 213 / 255, blue: 193 / 255)
    static let brown = Color(red: 133 / 255, green: 75 / 255, blue: 40 / 255)
    static let squareSize = CGFloat(50)
    static let black = Color(.black)
    static let white = Color(.white)

    static var whiteSquaresColor = lightBrown
    static var blackSquaresColor = brown
    static let letters = ["A", "B", "C", "D", "E", "F", "G", "H"]
    
    
    // debugging
    static var attackDebugMode = false
    
    
}
