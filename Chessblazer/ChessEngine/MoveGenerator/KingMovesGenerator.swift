//
//  KingMovesGenerator.swift
//  Chessblazer
//
//  Created by sergiusz on 10/10/2024.
//

import Foundation

func generateKingMovesBitboard(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move]) {
    let attackedSquares = generateAllAttackedSquares(bitboards: bitboards, currentColor: currentColor)
    var friendlyMask = Bitboard(0)
    var kingBitboard = Bitboard(0)
        
    var pieceValue = 0
    
    if currentColor == .white {
        kingBitboard = bitboards[Piece.ColoredPieces.whiteKing.rawValue]!
        pieceValue = Piece.ColoredPieces.whiteKing.rawValue
        friendlyMask = Magic.whitePiecesBitboards(bitboards: bitboards)
        
        
    } else {
        kingBitboard = bitboards[Piece.ColoredPieces.blackKing.rawValue]!
        pieceValue = Piece.ColoredPieces.blackKing.rawValue
        friendlyMask = Magic.blackPiecesBitboards(bitboards: bitboards)
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

func generateCastles(bitboards: [Int: Bitboard], currentColor: Piece.Color, moves: inout [Move], castlesAvailable: Set<Character>) {
    let attackedSquares = generateAllAttackedSquares(bitboards: bitboards, currentColor: currentColor)
    
    if currentColor == .white {
        let kingBitboard = bitboards[Piece.ColoredPieces.whiteKing.rawValue]!
        let friendlyMask = Magic.allPieces(bitboards: bitboards)


        let isUnderAttack = kingBitboard & attackedSquares != 0
        if !isUnderAttack {
            
            let rooksBitboard = bitboards[Piece.ColoredPieces.whiteRook.rawValue]!
            

            let piecesRank1 = friendlyMask & Bitboard.Masks.rank1
            let rooksKing = rooksBitboard | kingBitboard
            
            let rightRookToKing = Bitboard(144)
            let rightCorrectPositions = rooksKing & rightRookToKing == rightRookToKing
            let isRightPathClear = Bitboard(96) & piecesRank1 == 0
            let isRightPathNotUnderAttack = attackedSquares & Bitboard(96) == 0
            let isRightPossible = isRightPathClear && isRightPathNotUnderAttack && rightCorrectPositions

            
            let leftRookToKing = Bitboard(17)
            let leftCorrectPositions = rooksKing & leftRookToKing == leftRookToKing
            let isLeftPathClear = Bitboard(14) & piecesRank1 == 0
            let isLeftPathNotUnderAttack = attackedSquares & Bitboard(12) == 0
            let isLeftPossible = isLeftPathClear && isLeftPathNotUnderAttack && leftCorrectPositions
            
            
            if isRightPossible && castlesAvailable.contains("K") {
                let move = Move(fromSquare: 4, targetSquare: 7, kingValue: Piece.ColoredPieces.whiteKing.rawValue, rookValue: Piece.ColoredPieces.whiteRook.rawValue,kingDestination: 6, rookDestination: 5)
                moves.append(move)
            }
            
            if isLeftPossible && castlesAvailable.contains("Q") {
                moves.append(Move(fromSquare: 4, targetSquare: 0, kingValue: Piece.ColoredPieces.whiteKing.rawValue, rookValue: Piece.ColoredPieces.whiteRook.rawValue, kingDestination: 2, rookDestination: 3))
            }
        }
        
    } else {
        let kingBitboard = bitboards[Piece.ColoredPieces.blackKing.rawValue]!
        let friendlyMask = Magic.allPieces(bitboards: bitboards)
        let isUnderAttack = kingBitboard & attackedSquares != 0

        if !isUnderAttack {
            let rooksBitboard = bitboards[Piece.ColoredPieces.blackRook.rawValue]!
            let piecesRank8 = friendlyMask & Bitboard.Masks.rank8
            let rooksKing = rooksBitboard | kingBitboard
            
            let rightRookToKing = Bitboard(10376293541461622784)
            let rightCorrectPositions = rooksKing & rightRookToKing == rightRookToKing
            let isRightPathClear = Bitboard(6917529027641081856) & piecesRank8 == 0
            let isRightPathNotUnderAttack = attackedSquares & Bitboard(6917529027641081856) == 0
            let isRightPossible = isRightPathClear && isRightPathNotUnderAttack && rightCorrectPositions

            let leftRookToKing = Bitboard(1224979098644774912)
            let leftCorrectPositions = rooksKing & leftRookToKing == leftRookToKing
            let isLeftPathClear = Bitboard(1008806316530991104) & piecesRank8 == 0
            let isLeftPathNotUnderAttack = attackedSquares & Bitboard(864691128455135232) == 0
            let isLeftPossible = isLeftPathClear && isLeftPathNotUnderAttack && leftCorrectPositions
            
            if isRightPossible && castlesAvailable.contains("k") {
                moves.append(Move(fromSquare: 60, targetSquare: 63, kingValue: Piece.ColoredPieces.blackKing.rawValue, rookValue: Piece.ColoredPieces.blackRook.rawValue, kingDestination: 62, rookDestination: 61))
            }
            
            if isLeftPossible && castlesAvailable.contains("q") {
                moves.append(Move(fromSquare: 60, targetSquare: 56, kingValue: Piece.ColoredPieces.blackKing.rawValue, rookValue: Piece.ColoredPieces.blackRook.rawValue, kingDestination: 58, rookDestination: 59))
            }
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
