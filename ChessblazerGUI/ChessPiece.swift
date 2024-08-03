//
//  ChessPiecee.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 01/08/2024.
//

typealias PieceValue = Int
import SwiftUI
import Foundation
class ChessPiece {
    static let pieceImage: [PieceValue: Image] = [
        18: Image(.blackpawn),
        21: Image(.blackrook),
        19: Image(.blackknight),
        20: Image(.blackbishop),
        22: Image(.blackqueen),
        17: Image(.blackking),
        10: Image(.whitepawn),
        13: Image(.whiterook),
        11: Image(.whiteknight),
        12: Image(.whitebishop),
        14: Image(.whitequeen),
        9: Image(.whiteking),
    ]
}

