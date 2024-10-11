//
//  KingMovesGenerator.swift
//  Chessblazer
//
//  Created by sergiusz on 10/10/2024.
//

import Foundation


func generateKingMovesBitboard(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move], castlesAvailable: Set<Character>) {
    let attackedSquares = generateAllAttackedSquares(bitboards: bitboards, currentColor: currentColor)
    var friendlyMask = Bitboard(0)
    var kingBitboard = Bitboard(1) << Bitboard(square)
    let isUnderAttack = attackedSquares & kingBitboard == kingBitboard
    
    var pieceValue = 0
    
    if currentColor == .white {
        pieceValue = Piece.ColoredPieces.whiteKing.rawValue
        friendlyMask = Magic.whitePiecesBitboards(bitboards: bitboards)
        let rooks = bitboards[Piece.ColoredPieces.whiteRook.rawValue]!
        let rightRookToKing = Bitboard(144)
        let leftRookToKing = Bitboard(17)
        let rooksKing = rooks | kingBitboard
        
        
        let rank1 = (rooksKing | friendlyMask) | attackedSquares
        let isRightPossible = rank1 & Bitboard(240) == rightRookToKing
        let isLeftPossible = rank1 & Bitboard(31) == leftRookToKing
        
        if !isUnderAttack {
            if isRightPossible && castlesAvailable.contains("K") {
                let move = Move(fromSquare: 4, targetSquare: 7, kingValue: Piece.ColoredPieces.whiteKing.rawValue, rookValue: Piece.ColoredPieces.whiteRook.rawValue,kingDestination: 6, rookDestination: 5)
                moves.append(move)
            }
            
            if isLeftPossible && castlesAvailable.contains("Q") {
                
                moves.append(Move(fromSquare: 4, targetSquare: 0, kingValue: Piece.ColoredPieces.blackKing.rawValue, rookValue: Piece.ColoredPieces.blackRook.rawValue, kingDestination: 2, rookDestination: 3))
            }
        }
        
        
    } else {
        pieceValue = Piece.ColoredPieces.blackKing.rawValue

        friendlyMask = Magic.blackPiecesBitboards(bitboards: bitboards)
        let rooks = bitboards[Piece.ColoredPieces.blackRook.rawValue]!
        let rightRookToKing = Bitboard(10376293541461622784)
        let leftRookToKing = Bitboard(1224979098644774912)
        let rooksKing = rooks | kingBitboard
        
        
        let rank8 = (rooksKing | friendlyMask) | attackedSquares
        let isRightPossible = rank8 & Bitboard(17293822569102704640) == rightRookToKing
        let isLeftPossible = rank8 & Bitboard(2233785415175766016) == leftRookToKing
        
        if !isUnderAttack {
            if isRightPossible && castlesAvailable.contains("k") {
                moves.append(Move(fromSquare: 60, targetSquare: 63, kingValue: Piece.ColoredPieces.blackKing.rawValue, rookValue: Piece.ColoredPieces.blackRook.rawValue, kingDestination: 62, rookDestination: 61))
            }
            
            if isLeftPossible && castlesAvailable.contains("q") {
                moves.append(Move(fromSquare: 60, targetSquare: 56, kingValue: Piece.ColoredPieces.blackKing.rawValue, rookValue: Piece.ColoredPieces.blackRook.rawValue, kingDestination: 58, rookDestination: 59))
            }
        }
        
    }
    
    while kingBitboard != 0 {
        let square = Bitboard.popLSB(&kingBitboard)
        let king = Bitboard(1) << Bitboard(square)
        var movesBitboard = generateKingAttacks(king: king) & ~friendlyMask & ~attackedSquares
        
        while movesBitboard != 0 {
            let targetSquare = Bitboard.popLSB(&movesBitboard)
            let move = Move(fromSquare: square, targetSquare: targetSquare, pieceValue: pieceValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards))
            moves.append(move)
        }
    }
    
}

func generateKingAttacks(king: Bitboard) -> Bitboard {
    var attacks = king.eastOne() | king.westOne()
    let kingSet = king | attacks
    attacks = attacks | (kingSet.northOne() | kingSet.southOne())
    return attacks
}
func generateKingAttacks(square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    
    var kingBitboard = Bitboard(1) << Bitboard(square)
    
    let square = Bitboard.popLSB(&kingBitboard)
    let king = Bitboard(1) << Bitboard(square)
    let movesBitboard = generateKingAttacks(king: king) & ~friendlyBitboard
    return movesBitboard
    
}
