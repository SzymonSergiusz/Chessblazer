//
//  PieceSquareTables.swift
//  Chessblazer
//
//  Created by sergiusz on 06/08/2024.
//

import Foundation

extension Array where Element == Int {
    func mirrored() -> [Int] {
        var mirroredTable = [Int]()
        for i in stride(from: 56, through: 0, by: -8) {
            mirroredTable.append(contentsOf: self[i..<i+8])
        }
        return mirroredTable
    }
}

struct PieceSquareTables {
    static func getTable(piece: Int, eval: Int = 0) -> [Int] {
        
        switch Piece.ColoredPieces(rawValue: piece) {

        case .some(.empty):
            return [Int]()
        case .some(.blackKing):
            return getKingTable(currentBoardEval: eval).mirrored()
        case .some(.blackPawn):
            return pawnTable.mirrored()
        case .some(.blackQueen):
            return queenTable.mirrored()
        case .some(.blackKnight):
            return knightTable.mirrored()
        case .some(.blackBishop):
            return bishopTable.mirrored()
        case .some(.blackRook):
            return rookTable.mirrored()
        case .some(.whiteKing):
            return getKingTable(currentBoardEval: eval)
        case .some(.whitePawn):
            return pawnTable
        case .some(.whiteQueen):
            return queenTable
        case .some(.whiteKnight):
            return knightTable
        case .some(.whiteBishop):
            return bishopTable
        case .some(.whiteRook):
            return rookTable
        case .none:
            return [Int]()
        }
        
    }
    
    static let pawnTable: [Int] = [
        0,  0,  0,  0,  0,  0,  0,  0,
        5, 10, 10,-20,-20, 10, 10,  5,
        5, -5,-10,  0,  0,-10, -5,  5,
        0,  0,  0, 20, 20,  0,  0,  0,
        5,  5, 10, 25, 25, 10,  5,  5,
        10, 10, 20, 30, 30, 20, 10, 10,
        50, 50, 50, 50, 50, 50, 50, 50,
        0,  0,  0,  0,  0,  0,  0,  0,
    ]
    
    static let knightTable: [Int] = [
        -50,-40,-30,-30,-30,-30,-40,-50,
         -40,-20,  0,  5,  5,  0,-20,-40,
         -30,  5, 10, 15, 15, 10,  5,-30,
         -30,  0, 15, 20, 20, 15,  0,-30,
         -30,  5, 15, 20, 20, 15,  5,-30,
         -30,  0, 10, 15, 15, 10,  0,-30,
         -40,-20,  0,  0,  0,  0,-20,-40,
         -50,-40,-30,-30,-30,-30,-40,-50,
    ]
    
    static let bishopTable: [Int] = [
        -20,-10,-10,-10,-10,-10,-10,-20,
         -10,  5,  0,  0,  0,  0,  5,-10,
         -10, 10, 10, 10, 10, 10, 10,-10,
         -10,  0, 10, 10, 10, 10,  0,-10,
         -10,  5,  5, 10, 10,  5,  5,-10,
         -10,  0,  5, 10, 10,  5,  0,-10,
         -10,  0,  5, 10, 10,  5,  0,-10,
         -20,-10,-10,-10,-10,-10,-10,-20,
    ]
    
    static let rookTable: [Int] = [
        0,  0,  0,  5,  5,  0,  0,  0,
        -5,  0,  0,  0,  0,  0,  0, -5,
        -5,  0,  0,  0,  0,  0,  0, -5,
        -5,  0,  0,  0,  0,  0,  0, -5,
        -5,  0,  0,  0,  0,  0,  0, -5,
        -5,  0,  0,  0,  0,  0,  0, -5,
        5, 10, 10, 10, 10, 10, 10,  5,
        0,  0,  0,  0,  0,  0,  0,  0,
    ]
    
    static let queenTable: [Int] = [
        -20,-10,-10, -5, -5,-10,-10,-20,
         -10,  0,  5,  0,  0,  0,  0,-10,
         -10,  5,  5,  5,  5,  5,  0,-10,
         0,  0,  5,  5,  5,  5,  0, -5,
         -5,  0,  5,  5,  5,  5,  0, -5,
         -10,  0,  5,  5,  5,  5,  0,-10,
         -10,  0,  0,  0,  0,  0,  0,-10,
         -20,-10,-10, -5, -5,-10,-10,-20,
    ]
    
    static let kingMidgameTable: [Int] = [
        20, 30, 10,  0,  0, 10, 30, 20,
        20, 20,  0,  0,  0,  0, 20, 20,
        -10,-20,-20,-20,-20,-20,-20,-10,
        -20,-30,-30,-40,-40,-30,-30,-20,
        -30,-40,-40,-50,-50,-40,-40,-30,
        -30,-40,-40,-50,-50,-40,-40,-30,
        -30,-40,-40,-50,-50,-40,-40,-30,
        -30,-40,-40,-50,-50,-40,-40,-30,
    ]
    
    static let kingEndgameTable: [Int] = [
        0,  10,  20,  30,  30,  20,  10,   0,
       10,  20,  30,  40,  40,  30,  20,  10,
       20,  30,  40,  50,  50,  40,  30,  20,
       30,  40,  50,  60,  60,  50,  40,  30,
       30,  40,  50,  60,  60,  50,  40,  30,
       20,  30,  40,  50,  50,  40,  30,  20,
       10,  20,  30,  40,  40,  30,  20,  10,
        0,  10,  20,  30,  30,  20,  10,   0
    ]
    
    static func getKingTable(currentBoardEval: Int) -> [Int] {
//        for now 2000 should be enogh
        if abs(currentBoardEval) < 2000 {
            return kingEndgameTable
        } else {
            return kingMidgameTable
        }
    }
    
}
