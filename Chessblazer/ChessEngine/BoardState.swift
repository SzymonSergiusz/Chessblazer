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
    var currentTurnColor: Piece.Color = .white
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
//    var boardState : BoardState
}


