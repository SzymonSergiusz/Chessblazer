//
//  BoardUtils.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 03/08/2024.
//

import Foundation

class BoardUtils {
    static func squareToNotation(square: Int) -> String {
        let ranks = square / 8 + 1
        let files = square % 8
        let letters = "abcdefgh"

        guard ranks >= 1 && ranks <= 8 && files >= 0 && files < 8 else {
            return "Invalid square"
        }

        let fileLetter = letters[letters.index(letters.startIndex, offsetBy: files)]
        return "\(fileLetter)\(ranks)"
    }
}
