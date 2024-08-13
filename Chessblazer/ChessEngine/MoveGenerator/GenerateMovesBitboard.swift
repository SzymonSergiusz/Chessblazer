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

func generateWhitePawnMoves(game: Game, square: Int, moves: inout [Move]) {
    let empty = emptySquaresBitboard(bitboards: game.bitboards)
    
    let pawn = Bitboard(1 << square)
    var movesBitboard = whitePawnOnePush(whitePawns: pawn, emptySquares: empty) | whitePawnDoublePush(whitePawns: pawn, emptySquares: empty) | (generateWhitePawnAttacks(whitePawns: pawn) & Magic.blackPiecesBitboards(bitboards: game.bitboards))
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        moves.append(Move(fromSquare: square, targetSquare: targetSquare))
    }
}


func generateBlackPawnMoves(game: Game, square: Int, moves: inout [Move]) {
    
    let empty = emptySquaresBitboard(bitboards: game.bitboards)
    
    let pawn = Bitboard(1 << square)
    var movesBitboard = blackPawnOnePush(blackPawns: pawn, emptySquares: empty) | blackPawnDoublePush(blackPawns: pawn, emptySquares: empty) | (generateBlackPawnAttacks(blackPawns: pawn) & Magic.whitePiecesBitboards(bitboards: game.bitboards))
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        moves.append(Move(fromSquare: square, targetSquare: targetSquare))
    }
}

func generatePawnMoves(game: Game, square: Int, moves: inout [Move]) {

    if game.currentTurnColor == .white {
        generateWhitePawnMoves(game: game, square: square, moves: &moves)
    } else {
        generateBlackPawnMoves(game: game, square: square, moves: &moves)
    }
    
    
}


func generateKingAttacks(king: Bitboard) -> Bitboard {
    var attacks = king.eastOne() | king.westOne()
    let kingSet = king | attacks
    attacks = attacks | (kingSet.northOne() | kingSet.southOne())
    return attacks
}

// # rooks #


func generateRookMoves(game: Game, square: Int, moves: inout [Move]) {
    let whitePieces = Magic.whitePiecesBitboards(bitboards: game.bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: game.bitboards)
    let allPieces = whitePieces | blackPieces
    #warning("no check xray mask")
    let blockerBitboard = allPieces & Magic.rookMasks[square] // & checkRayMask
//    let key: UInt64 = Magic.hashKeyRook(blockerBitboard: blockerBitboard, square: square)

//    var movesBitboard = Magic.rookLookupTable[square]![key]!
    var movesBitboard = Magic.rookLookupTable[Magic.KeyTuple(square, blockerBitboard.rawValue)]!

    // seems useless
    if game.currentTurnColor == .white {
        movesBitboard = movesBitboard & ~whitePieces
    } else {
        movesBitboard = movesBitboard & ~blackPieces
    }
    
    #warning("no pin mask check yet")
    //movesBitboard = movesBitboard & getPinMask()

    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        moves.append(Move(fromSquare: square, targetSquare: targetSquare))
    }
}

func generateBishopMoves(game: Game, square: Int, moves: inout [Move]) {
    
    let whitePieces = Magic.whitePiecesBitboards(bitboards: game.bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: game.bitboards)
    let allPieces = whitePieces | blackPieces
    
    let blockerBitboard = allPieces & Magic.bishopMasks[square] // & checkRayMask
    
//    let key: UInt64 = Magic.hashKeyBishop(blockerBitboard: blockerBitboard, square: square)
//    var movesBitboard = Magic.bishopLookupTable[square]![key]!
        
    var movesBitboard = Magic.bishopLookupTable[Magic.KeyTuple(square, blockerBitboard.rawValue)]!
    
    if game.currentTurnColor == .white {
        movesBitboard = movesBitboard & ~whitePieces
    } else {
        movesBitboard = movesBitboard & ~blackPieces
    }
    
    #warning("no pin mask check yet")
    //movesBitboard = movesBitboard & getPinMask()

    while movesBitboard != 0 {
        
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        moves.append(Move(fromSquare: square, targetSquare: targetSquare))
    }
}

func generateQueenMoves(game: Game, square: Int, moves: inout [Move]) {
    generateRookMoves(game: game, square: square, moves: &moves)
    generateBishopMoves(game: game, square: square, moves: &moves)
    
}



func generateKingMoves(game: Game, square: Int, moves: inout [Move]) {
    var friendlyMask = Bitboard(0)
    var kingBitboard = Bitboard(1 << square)
    
    if game.currentTurnColor == .white {
        friendlyMask = Magic.whitePiecesBitboards(bitboards: game.bitboards)
    } else {
        friendlyMask = Magic.blackPiecesBitboards(bitboards: game.bitboards)
    }
    
    while kingBitboard != 0 {
        let square = Bitboard.popLSB(&kingBitboard)
        let king = Bitboard(1 << square)
        var movesBitboard = generateKingAttacks(king: king) & ~friendlyMask
        
        while movesBitboard != 0 {
            let targetSquare = Bitboard.popLSB(&movesBitboard)
            moves.append(Move(fromSquare: square, targetSquare: targetSquare))
        }
    }
    
}

func generateKnightMoves(game: Game, square: Int, moves: inout [Move]) {
    var friendlyMask = Bitboard(0)
    var knightBitboard = Bitboard(1 << square)
    if game.currentTurnColor == .white {
        friendlyMask = Magic.whitePiecesBitboards(bitboards: game.bitboards)
    } else {
        friendlyMask = Magic.blackPiecesBitboards(bitboards: game.bitboards)
    }
    
    while knightBitboard != 0 {
        let square = Bitboard.popLSB(&knightBitboard)
        let knight = Bitboard(1 << square)
        var movesBitboard = generateKnightAttacks(bitboard: knight) & ~friendlyMask
        while movesBitboard != 0 {
            let targetSquare = Bitboard.popLSB(&movesBitboard)
            moves.append(Move(fromSquare: square, targetSquare: targetSquare))
        }
    }
}

func generateAllPossibleMoves(game: Game, moves: inout [Move]) {
    moves.removeAll()
    for bitboard in game.bitboards {
        if Piece.checkColor(piece: bitboard.key) == game.currentTurnColor {
            var pieceSquares = [Int]()
            var copyBitboard: Bitboard = bitboard.value
            
            while copyBitboard != 0 {
                pieceSquares.append(Bitboard.popLSB(&copyBitboard))
            }
            let pieceType = Piece.getType(piece: bitboard.key)

            for square in pieceSquares {
                switch pieceType {
                case .queen:
                    generateQueenMoves(game: game, square: square, moves: &moves)
                
                case .bishop:
                    generateBishopMoves(game: game, square: square, moves: &moves)
                    
                case .rook:
                    generateRookMoves(game: game, square: square, moves: &moves)
                case .pawn:
                    generatePawnMoves(game: game, square: square, moves: &moves)
                case .king:
                    generateKingMoves(game: game, square: square, moves: &moves)
                    
                case .knight:
                    generateKnightMoves(game: game, square: square, moves: &moves)
                    
                default:
                    print("not found")
                    
                }
            }
        }
        
    }
}
