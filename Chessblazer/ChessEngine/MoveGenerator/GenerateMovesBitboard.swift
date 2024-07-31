//
//  GenerateMovesBitboard.swift
//  Chessblazer
//
//  Created by sergiusz on 30/07/2024.
//

import Foundation

enum KnightMoves: Int, CaseIterable {
    case noNoEa = 17
    case noEaEa = 10
    case soEaEa = -6
    case soSoEa = -15
    case noNoWe = 15
    case noWeWe = 6
    case soWeWe = -10
    case soSoWe = -17
    
    
    var mask: Bitboard {
        switch self {
        case .noNoEa, .soSoEa:
            return ~Bitboard.Masks.fileA
        case .noEaEa, .soEaEa:
            return ~Bitboard.Masks.fileAB
        case .noNoWe, .soSoWe:
            return ~Bitboard.Masks.fileH
        case .noWeWe, .soWeWe:
            return ~Bitboard.Masks.fileGH
        }
    }
}

func generateKnightAttacks(bitboard: Bitboard) -> Bitboard {
    let knightAttackBitboard: Bitboard =
        ((bitboard << 6) | (bitboard >> 10)) & ~Bitboard.Masks.fileGH |
        ((bitboard << 10) | (bitboard >> 6)) & ~Bitboard.Masks.fileAB |
        ((bitboard << 15) | (bitboard >> 17)) & ~Bitboard.Masks.fileH |
        ((bitboard << 17) | (bitboard >> 15)) & ~Bitboard.Masks.fileA
    
    return knightAttackBitboard
}
// # Pawns Attacks #
func generateWhitePawnAttacks(whitePawns: Bitboard) -> Bitboard {
    let whitePawnAttacks = ((whitePawns << 9) & ~Bitboard.Masks.fileA) |
        ((whitePawns << 7) & ~Bitboard.Masks.fileH)
    return whitePawnAttacks
}

func generateBlackPawnAttacks(blackPawns: Bitboard) -> Bitboard {
    let blackPawnAttacks = ((blackPawns >> 7) & ~Bitboard.Masks.fileA) | ((blackPawns >> 9) & ~Bitboard.Masks.fileH)
    return blackPawnAttacks
}

// # Pawns moves#
func emptySquaresBitboard(bitboards: [Int: Bitboard]) -> Bitboard {
    var notEmpty = Bitboard(0)
    for bitboard in bitboards {
        notEmpty = notEmpty | bitboard.value
    }
    
    return ~notEmpty
}

func whitePawnOnePush(whitePawns: Bitboard, emptySquares: Bitboard) -> Bitboard{
    return (whitePawns << 8) & emptySquares
}

func whitePawnDoublePush(whitePawns: Bitboard, emptySquares: Bitboard) -> Bitboard {
    let singlePush = whitePawnOnePush(whitePawns: whitePawns, emptySquares: emptySquares)
    return singlePush << 8 & emptySquares & Bitboard.Masks.rank4
}

func blackPawnOnePush(blackPawns: Bitboard, emptySquares: Bitboard) -> Bitboard{
    return (blackPawns >> 8) & emptySquares
}

func blackPawnDoublePush(blackPawns: Bitboard, emptySquares: Bitboard) -> Bitboard {
    let singlePush = blackPawnOnePush(blackPawns: blackPawns, emptySquares: emptySquares)
    return singlePush >> 8 & emptySquares & Bitboard.Masks.rank5
}

func kingAttacks(king: Bitboard) -> Bitboard {
    var attacks = king.eastOne() | king.westOne()
    let kingSet = king | attacks
    attacks = attacks | (kingSet.northOne() | kingSet.southOne())
    return attacks
}

// # rooks #


