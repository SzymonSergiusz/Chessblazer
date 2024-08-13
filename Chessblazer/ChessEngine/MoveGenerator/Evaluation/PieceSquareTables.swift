//
//  PieceSquareTables.swift
//  Chessblazer
//
//  Created by sergiusz on 06/08/2024.
//

import Foundation

class PieceSquareTables {
    
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
    
    /*
     
     -20,-10,-10, -5, -5,-10,-10,-20,
     -10,  0,  0,  0,  0,  0,  0,-10,
     -10,  0,  5,  5,  5,  5,  0,-10,
      -5,  0,  5,  5,  5,  5,  0, -5,
       0,  0,  5,  5,  5,  5,  0, -5,
     -10,  5,  5,  5,  5,  5,  0,-10,
     -10,  0,  5,  0,  0,  0,  0,-10,
     -20,-10,-10, -5, -5,-10,-10,-20
     
     */
    static let queenTable: [Int] = [
    
    
    
    ]
    
    
    
#warning("to check for blacks")
    static func getKnightTable(color: Piece.PieceColor) -> [Int] {
        if color == .white {
            return knightTable
        } else {
            
            return knightTable.reversed()
        }
    }
    
        
    static func getPawnTable(color: Piece.PieceColor) -> [Int] {
        if color == .white {
            return pawnTable
        } else {
            return pawnTable.reversed()
        }
    }
    
}
