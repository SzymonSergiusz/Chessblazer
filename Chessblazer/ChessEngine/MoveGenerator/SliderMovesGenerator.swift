//
//  SliderMovesGenerator.swift
//  Chessblazer
//
//  Created by sergiusz on 10/10/2024.
//

import Foundation
func generateRookMoves(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move]) {
    let whitePieces = Magic.whitePiecesBitboards(bitboards: bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: bitboards)
    let allPieces = whitePieces | blackPieces
    let blockerBitboard = allPieces & Rook.masks[square] // & checkRayMask
    var movesBitboard = Rook.lookUpTable[square]![magicIndex(magic: rookMagics[square], shift: rookShifts[square], blocker: blockerBitboard)]!
    var pieceValue = 0
    
    if currentColor == .white {
        movesBitboard = movesBitboard & ~whitePieces
        pieceValue = Piece.ColoredPieces.whiteRook.rawValue
    } else {
        movesBitboard = movesBitboard & ~blackPieces
        pieceValue = Piece.ColoredPieces.blackRook.rawValue

    }
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: pieceValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
    }
}
func generateRookAttacks(bitboards: [Int: Bitboard], square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    let whitePieces = Magic.whitePiecesBitboards(bitboards: bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: bitboards)
    let allPieces = whitePieces | blackPieces
    let blockerBitboard = allPieces & Rook.masks[square] // & checkRayMask
    var movesBitboard = Rook.lookUpTable[square]![magicIndex(magic: rookMagics[square], shift: rookShifts[square], blocker: blockerBitboard)]!
    movesBitboard = movesBitboard & ~friendlyBitboard
    return movesBitboard
}

func generateBishopMoves(bitboards: [Int: Bitboard], currentColor: Piece.Color,square: Int, moves: inout [Move]) {
    
    let whitePieces = Magic.whitePiecesBitboards(bitboards: bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: bitboards)
    let allPieces = whitePieces | blackPieces
    
    let blockerBitboard = allPieces & Bishop.masks[square] // & checkRayMask
    
    var movesBitboard = Bishop.lookUpTable[square]![magicIndex(magic: bishopMagics[square], shift: bishopShifts[square], blocker: blockerBitboard)]!
    
    var pieceValue = 0
    if currentColor == .white {
        movesBitboard = movesBitboard & ~whitePieces
        pieceValue = Piece.ColoredPieces.whiteBishop.rawValue
    } else {
        movesBitboard = movesBitboard & ~blackPieces
        pieceValue = Piece.ColoredPieces.blackBishop.rawValue

    }
    
    while movesBitboard != 0 {
        
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: pieceValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
    }
}


func generateBishopAttacks(bitboards: [Int: Bitboard], square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    let whitePieces = Magic.whitePiecesBitboards(bitboards: bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: bitboards)
    let allPieces = whitePieces | blackPieces
    let blockerBitboard = allPieces & Bishop.masks[square]
    var movesBitboard = Bishop.lookUpTable[square]![magicIndex(magic: bishopMagics[square], shift: bishopShifts[square], blocker: blockerBitboard)]!
    movesBitboard = movesBitboard & ~friendlyBitboard
    return movesBitboard
}

func generateQueenMoves(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move]) {
    var queenMoves = [Move]()
    let queen: Piece.ColoredPieces = currentColor == .white ? .whiteQueen : .blackQueen
    generateRookMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &queenMoves)
    generateBishopMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &queenMoves)
    queenMoves = queenMoves.map { move in
        move.pieceValue = queen.rawValue
        return move
    }
    moves.append(contentsOf: queenMoves)
}

func generateQueenAttacks(bitboards: [Int: Bitboard], square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    return generateBishopAttacks(bitboards: bitboards, square: square, friendlyBitboard: friendlyBitboard) | generateRookAttacks(bitboards: bitboards, square: square, friendlyBitboard: friendlyBitboard)
}
