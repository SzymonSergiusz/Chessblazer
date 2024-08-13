//
//  Evaluation.swift
//  Chessblazer
//
//  Created by sergiusz on 06/08/2024.
//

import Foundation

let evalPiecesValue: [Piece.ColoredPieces: Int] = [
    .whitePawn : 100,
    .whiteKnight : 320,
    .whiteBishop : 330,
    .whiteRook : 500,
    .whiteQueen : 900,
    .whiteKing : 20000,
    
    .blackPawn : -100,
    .blackKnight : -320,
    .blackBishop : -330,
    .blackRook : -500,
    .blackQueen : -900,
    .blackKing : -20000,
]

/*
Evaluation ideas:
 - use simplified eval func
 - endgame when both players' board value is below smth
 */
