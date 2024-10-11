//
//  BoardState.swift
//  Chessblazer
//
//  Created by sergiusz on 10/10/2024.
//

import Foundation

struct BoardState {
    var pawnAttackBitboard = Bitboard(0)
    var performedMovesList = [MoveData]()
    var castlesAvailable: Set<Character> = []
    var currentTurnColor: Piece.Color // = .white
    var bitboards: [Int: Bitboard] = initBitboards()
    var enPassant = "-"
    var currentValidMoves: [Move] = [Move]()
    
}

func initBitboards() -> [Int: Bitboard] {
    var bitboards = [Piece.ColoredPieces.RawValue : Bitboard]()
    for piece in Piece.ColoredPieces.allCases {
        if piece.rawValue != 0 {
            bitboards[piece.rawValue] = Bitboard(0)
        }
    }
    return bitboards
}



struct BoardData {
    var halfMoves = 0
    var hasGameEnded = false

}

struct MoveData {
    var piece: Int
    var turn: Int
    var color: Piece.Color
    var move: Move
    var capturedPiece: Int?
    var bitboards: [Piece.ColoredPieces.RawValue : Bitboard]
    var castles: Set<Character>
    var currentValidMoves: [Move]
}


