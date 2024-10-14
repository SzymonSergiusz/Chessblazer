//
//  PawnMovesGenerator.swift
//  Chessblazer
//
//  Created by sergiusz on 05/09/2024.
//

import Foundation

// Moves
func whitePawnOnePush(whitePawns: Bitboard, emptySquares: Bitboard) -> Bitboard {
    return (whitePawns << 8) & emptySquares
}

func whitePawnDoublePush(whitePawns: Bitboard, emptySquares: Bitboard) -> Bitboard {
    let singlePush = whitePawnOnePush(whitePawns: whitePawns, emptySquares: emptySquares)
    return (singlePush << 8) & emptySquares & Bitboard.Masks.rank4
}

func blackPawnOnePush(blackPawns: Bitboard, emptySquares: Bitboard) -> Bitboard{
    return (blackPawns >> 8) & emptySquares
}

func blackPawnDoublePush(blackPawns: Bitboard, emptySquares: Bitboard) -> Bitboard {
    let singlePush = blackPawnOnePush(blackPawns: blackPawns, emptySquares: emptySquares)
    return (singlePush >> 8) & emptySquares & Bitboard.Masks.rank5
}

// Attacks
func generateWhitePawnAttacks(whitePawns: Bitboard) -> Bitboard {
    let whitePawnAttacks = ((whitePawns << 9) & ~Bitboard.Masks.fileA) |
    ((whitePawns << 7) & ~Bitboard.Masks.fileH)
    return whitePawnAttacks
}

func generateBlackPawnAttacks(blackPawns: Bitboard) -> Bitboard {
    let blackPawnAttacks = ((blackPawns >> 7) & ~Bitboard.Masks.fileA) | ((blackPawns >> 9) & ~Bitboard.Masks.fileH)
    return blackPawnAttacks
}


func generateWhitePawnMoves(bitboards: [Int: Bitboard], square: Int, moves: inout [Move]) {
    let empty = emptySquaresBitboard(bitboards: bitboards)
    
    let pawn = Bitboard(1) << Bitboard(square)
    var movesBitboard = whitePawnOnePush(whitePawns: pawn, emptySquares: empty) | whitePawnDoublePush(whitePawns: pawn, emptySquares: empty) | (generateWhitePawnAttacks(whitePawns: pawn) & Magic.blackPiecesBitboards(bitboards: bitboards))
    
    
    
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        
        if pawn & Bitboard.Masks.rank7 == pawn {
            for piece in Piece.ColoredPieces.possibleWhitePromotions() {
                moves.append(
                    Move(
                        fromSquare: square,
                        targetSquare: targetSquare,
                        pieceValue: Piece.ColoredPieces.whitePawn.rawValue,
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.whitePawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
        }
    }
}

func generateWhitePawnAttacks(bitboards: [Int: Bitboard], square: Int, moves: inout [Move]) {
    let pawn = Bitboard(1) << Bitboard(square)
    var movesBitboard = generateWhitePawnAttacks(whitePawns: pawn)
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        
        if pawn & Bitboard.Masks.rank7 == pawn {
            for piece in Piece.ColoredPieces.possibleWhitePromotions() {
                moves.append(
                    Move(
                        fromSquare: square,
                        targetSquare: targetSquare,
                        pieceValue: Piece.ColoredPieces.whitePawn.rawValue,
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.whitePawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
        }
        
        
    }
}

func generateWhitePawnAttacks(square: Int) -> Bitboard {
    let pawn = UInt64(1) << square
    return generateWhitePawnAttacks(whitePawns: pawn)
}

func generateBlackPawnAttacks(bitboards: [Int: Bitboard], square: Int, moves: inout [Move]) {
    let pawn = Bitboard(1 << square)
    var movesBitboard = generateBlackPawnAttacks(blackPawns: pawn)
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        
        if pawn & Bitboard.Masks.rank2 == pawn {
            for piece in Piece.ColoredPieces.possibleBlackPromotions() {
                moves.append(
                    Move(
                        fromSquare: square,
                        targetSquare: targetSquare,
                        pieceValue: Piece.ColoredPieces.blackPawn.rawValue,
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.blackPawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
        }
        
        
        
    }
}

func generateBlackPawnAttacks(square: Int) -> Bitboard {
    let pawn = Bitboard(1 << square)
    return generateBlackPawnAttacks(blackPawns: pawn)
    
}



func generateBlackPawnMoves(bitboards: [Int: Bitboard], square: Int, moves: inout [Move]) {
    
    let empty = emptySquaresBitboard(bitboards: bitboards)
    
    let pawn = Bitboard(1 << square)
    var movesBitboard = blackPawnOnePush(blackPawns: pawn, emptySquares: empty) | blackPawnDoublePush(blackPawns: pawn, emptySquares: empty) | (generateBlackPawnAttacks(blackPawns: pawn) & Magic.whitePiecesBitboards(bitboards: bitboards))
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        
        if pawn & Bitboard.Masks.rank2 == pawn {
            for piece in Piece.ColoredPieces.possibleBlackPromotions() {
                moves.append(
                    Move(
                        fromSquare: square,
                        targetSquare: targetSquare,
                        pieceValue: Piece.ColoredPieces.blackPawn.rawValue,
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.blackPawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
        }
        
    }
}

func generatePawnMoves(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move]) {
    
    if currentColor == .white {
        generateWhitePawnMoves(bitboards: bitboards, square: square, moves: &moves)
    } else {
        generateBlackPawnMoves(bitboards: bitboards, square: square, moves: &moves)
    }
}
func generatePawnAttacks(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move]) {
    
    if currentColor.getOppositeColor() == .white {
        generateWhitePawnAttacks(bitboards: bitboards, square: square, moves: &moves)
    } else {
        generateBlackPawnAttacks(bitboards: bitboards, square: square, moves: &moves)
    }
}

func generatePawnAttacks(currentColor: Piece.Color, square: Int) -> Bitboard {
    
    if currentColor == .white {
        return generateWhitePawnAttacks(square: square)
    } else {
        return generateBlackPawnAttacks(square: square)
        
    }
}


func enPassantCheck(bitboards: [Int: Bitboard], lastMove: Move) -> [Move] {
    var moves = [Move]()
    guard let from = lastMove.fromSquare, let target = lastMove.targetSquare else { return [Move]() }
    
    if lastMove.pieceValue == Piece.ColoredPieces.whitePawn.rawValue {
        if (8...15).contains(from) && (24...31).contains(target) {
            var blackPawns = bitboards[Piece.ColoredPieces.blackPawn.rawValue]! & Bitboard.Masks.rank4
            while (blackPawns != 0) {
                let blackPawn = Bitboard.popLSB(&blackPawns)
                if blackPawn-1 == target || blackPawn+1 == target {
                    moves.append(Move(fromSquare: blackPawn, targetSquare: target - 8, enPasssantCapture: target, pieceValue: Piece.ColoredPieces.blackPawn.rawValue, captureValue: Piece.ColoredPieces.whitePawn.rawValue))
                }
            }
        }
    } else if lastMove.pieceValue == Piece.ColoredPieces.blackPawn.rawValue {
        if (48...55).contains(from) && (32...39).contains(target) {
            var whitePawns = bitboards[Piece.ColoredPieces.whitePawn.rawValue]! & Bitboard.Masks.rank5
            while (whitePawns != 0) {
                let whitePawn = Bitboard.popLSB(&whitePawns)
                if whitePawn-1 == target || whitePawn+1 == target {
                    moves.append(Move(fromSquare: whitePawn, targetSquare: target+8, enPasssantCapture: target, pieceValue: Piece.ColoredPieces.whitePawn.rawValue, captureValue: Piece.ColoredPieces.blackPawn.rawValue))
                }
            }
            
        }
    }
//    if !moves.isEmpty {
//        let movesSet = Set(moves)
//        
//        for m in movesSet {
//            print(m.moveToNotation())
//        }
//    }
    return Array(Set(moves))
}
