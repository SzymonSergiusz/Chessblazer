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


func generateWhitePawnMoves(game: Game, square: Int, moves: inout [Move]) {
    let empty = emptySquaresBitboard(bitboards: game.bitboards)
    
    let pawn = Bitboard(1) << Bitboard(square)
    var movesBitboard = whitePawnOnePush(whitePawns: pawn, emptySquares: empty) | whitePawnDoublePush(whitePawns: pawn, emptySquares: empty) | (generateWhitePawnAttacks(whitePawns: pawn) & Magic.blackPiecesBitboards(bitboards: game.bitboards))
    
    
    
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        
        if pawn & Bitboard.Masks.rank7 == pawn {
            for piece in Piece.ColoredPieces.possibleWhitePromotions() {
                moves.append(
                    Move(
                        fromSquare: square,
                        targetSquare: targetSquare,
                        pieceValue: Piece.ColoredPieces.whitePawn.rawValue,
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: game.bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.whitePawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: game.bitboards)))
        }
    }
}

func generateWhitePawnAttacks(game: Game, square: Int, moves: inout [Move]) {
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
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: game.bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.whitePawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: game.bitboards)))
        }
        
        
    }
}

func generateWhitePawnAttacks(game: Game, square: Int) -> Bitboard {
    let pawn = UInt64(1) << square
    return generateWhitePawnAttacks(whitePawns: pawn)
}

func generateBlackPawnAttacks(game: Game, square: Int, moves: inout [Move]) {
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
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: game.bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.blackPawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: game.bitboards)))
        }
        
        
        
    }
}

func generateBlackPawnAttacks(game: Game, square: Int) -> Bitboard {
    let pawn = Bitboard(1 << square)
    return generateBlackPawnAttacks(blackPawns: pawn)
    
}



func generateBlackPawnMoves(game: Game, square: Int, moves: inout [Move]) {
    
    let empty = emptySquaresBitboard(bitboards: game.bitboards)
    
    let pawn = Bitboard(1 << square)
    var movesBitboard = blackPawnOnePush(blackPawns: pawn, emptySquares: empty) | blackPawnDoublePush(blackPawns: pawn, emptySquares: empty) | (generateBlackPawnAttacks(blackPawns: pawn) & Magic.whitePiecesBitboards(bitboards: game.bitboards))
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        
        if pawn & Bitboard.Masks.rank2 == pawn {
            for piece in Piece.ColoredPieces.possibleBlackPromotions() {
                moves.append(
                    Move(
                        fromSquare: square,
                        targetSquare: targetSquare,
                        pieceValue: Piece.ColoredPieces.blackPawn.rawValue,
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: game.bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.blackPawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: game.bitboards)))
        }
        
    }
}

func generatePawnMoves(game: Game, square: Int, moves: inout [Move]) {
    
    if game.currentTurnColor == .white {
        generateWhitePawnMoves(game: game, square: square, moves: &moves)
    } else {
        generateBlackPawnMoves(game: game, square: square, moves: &moves)
    }
}
func generatePawnAttacks(game: Game, square: Int, moves: inout [Move]) {
    
    if game.currentTurnColor.getOppositeColor() == .white {
        generateWhitePawnAttacks(game: game, square: square, moves: &moves)
    } else {
        generateBlackPawnAttacks(game: game, square: square, moves: &moves)
    }
}

func generatePawnAttacks(game: Game, square: Int, color: Piece.PieceColor) -> Bitboard {
    
    if color == .white {
        return generateWhitePawnAttacks(game: game, square: square)
    } else {
        return generateBlackPawnAttacks(game: game, square: square)
        
    }
}
