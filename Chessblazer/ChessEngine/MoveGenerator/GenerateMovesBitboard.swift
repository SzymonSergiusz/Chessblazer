//
//  GenerateMovesBitboard.swift
//  Chessblazer
//
//  Created by sergiusz on 30/07/2024.
//

import Foundation

func generateKnightAttacks(bitboard: UInt64) -> UInt64 {

    let half1: UInt64 = ((bitboard << 15) | (bitboard >> 17)) & ~Bitboard.Masks.fileH |
                       ((bitboard << 17) | (bitboard >> 15)) & ~Bitboard.Masks.fileA
    
    let half2: UInt64 = ((bitboard << 6) | (bitboard >> 10)) & ~Bitboard.Masks.fileGH |
                      ((bitboard << 10) | (bitboard >> 6)) & ~Bitboard.Masks.fileAB
    
    let moves = half1 | half2
    
    return moves
}


func emptySquaresBitboard(bitboards: [Int: Bitboard]) -> Bitboard {
    var notEmpty = Bitboard(0)
    for bitboard in bitboards {
        notEmpty = notEmpty | bitboard.value
    }
    
    return ~notEmpty
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
    let blockerBitboard = allPieces & Rook.masks[square] // & checkRayMask
    var movesBitboard = Rook.lookUpTable[square]![magicIndex(magic: rookMagics[square], shift: rookShifts[square], blocker: blockerBitboard)]!
    
    // seems useless
    if game.currentTurnColor == .white {
        movesBitboard = movesBitboard & ~whitePieces
    } else {
        movesBitboard = movesBitboard & ~blackPieces
    }
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        moves.append(Move(fromSquare: square, targetSquare: targetSquare))
    }
}


func generateRookAttacks(game: Game, square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    let whitePieces = Magic.whitePiecesBitboards(bitboards: game.bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: game.bitboards)
    let allPieces = whitePieces | blackPieces
    let blockerBitboard = allPieces & Rook.masks[square] // & checkRayMask
    var movesBitboard = Rook.lookUpTable[square]![magicIndex(magic: rookMagics[square], shift: rookShifts[square], blocker: blockerBitboard)]!
    movesBitboard = movesBitboard & ~friendlyBitboard
    return movesBitboard
}

func generateBishopAttacks(game: Game, square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    let whitePieces = Magic.whitePiecesBitboards(bitboards: game.bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: game.bitboards)
    let allPieces = whitePieces | blackPieces
    let blockerBitboard = allPieces & Bishop.masks[square]
    var movesBitboard = Bishop.lookUpTable[square]![magicIndex(magic: bishopMagics[square], shift: bishopShifts[square], blocker: blockerBitboard)]!
    movesBitboard = movesBitboard & ~friendlyBitboard
    return movesBitboard
}

func generateQueenAttacks(game: Game, square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    return generateBishopAttacks(game: game, square: square, friendlyBitboard: friendlyBitboard) | generateRookAttacks(game: game, square: square, friendlyBitboard: friendlyBitboard)
}

func generateKingAttacks(game: Game, square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    
    var kingBitboard = Bitboard(1 << square)
    
        let square = Bitboard.popLSB(&kingBitboard)
        let king = Bitboard(1 << square)
        let movesBitboard = generateKingAttacks(king: king) & ~friendlyBitboard
        return movesBitboard
    
}


func generateBishopMoves(game: Game, square: Int, moves: inout [Move]) {
    
    let whitePieces = Magic.whitePiecesBitboards(bitboards: game.bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: game.bitboards)
    let allPieces = whitePieces | blackPieces
    
    let blockerBitboard = allPieces & Bishop.masks[square] // & checkRayMask
    
    var movesBitboard = Bishop.lookUpTable[square]![magicIndex(magic: bishopMagics[square], shift: bishopShifts[square], blocker: blockerBitboard)]!
    
    
    if game.currentTurnColor == .white {
        movesBitboard = movesBitboard & ~whitePieces
    } else {
        movesBitboard = movesBitboard & ~blackPieces
    }
    
    while movesBitboard != 0 {
        
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        moves.append(Move(fromSquare: square, targetSquare: targetSquare))
    }
}

func generateQueenMoves(game: Game, square: Int, moves: inout [Move]) {
    generateRookMoves(game: game, square: square, moves: &moves)
    generateBishopMoves(game: game, square: square, moves: &moves)
}



func generateKingMoves(game: Game, square: Int, moves: inout [Move], attackedSquares: [Int] = [Int]()) {
    var friendlyMask = Bitboard(0)
    var kingBitboard = Bitboard(1 << square)
    
    if game.currentTurnColor == .white {
        friendlyMask = Magic.whitePiecesBitboards(bitboards: game.bitboards)
        
        let board = game.toBoardArrayRepresentation()
        if game.castlesAvailable.contains("K") {
            let rightCastle = [9, 0, 0, 13]
            let isRightPossible = board[4...7].elementsEqual(rightCastle) && !attackedSquares.contains(board[4...6])
            if isRightPossible {
                //                print("right is possible")
                let move = CastlingMove(fromSquare: 4, targetSquare: 7, rookDestination: 5, kingDestination: 6)
                moves.append(move)
                //                print(move.self)
            }
        }
        
        if game.castlesAvailable.contains("Q") {
            
            let leftCastle = [13, 0, 0, 0, 9]
            let isLeftPossible = board[0...4].elementsEqual(leftCastle) && !attackedSquares.contains(board[1...4])
            if isLeftPossible {
                moves.append(CastlingMove(fromSquare: 4, targetSquare: 0, rookDestination: 3, kingDestination: 2))
            }
        }
        
    } else {
        friendlyMask = Magic.blackPiecesBitboards(bitboards: game.bitboards)
        let board = game.toBoardArrayRepresentation()
        
        if game.castlesAvailable.contains("k") {
            let rightCastle = [17, 0, 0, 21]
            let isRightPossible = board[60...63].elementsEqual(rightCastle) && !attackedSquares.contains(60...62)
            if isRightPossible {
                //print("right is possible")
                let move = CastlingMove(fromSquare: 60, targetSquare: 63, rookDestination: 61, kingDestination: 62)
                moves.append(move)
                //print(move.self)
            }
        }
        
        if game.castlesAvailable.contains("q") {
            
            let leftCastle = [21, 0, 0, 0, 17]
            let isLeftPossible = board[56...60].elementsEqual(leftCastle) && !attackedSquares.contains(57...60)
            if isLeftPossible {
                moves.append(CastlingMove(fromSquare: 60, targetSquare: 56, rookDestination: 59, kingDestination: 58))
            }
        }
        
        
    }
    
    while kingBitboard != 0 {
        let square = Bitboard.popLSB(&kingBitboard)
        let king = Bitboard(1 << square)
        var movesBitboard = generateKingAttacks(king: king) & ~friendlyMask
        
        while movesBitboard != 0 {
            let targetSquare = Bitboard.popLSB(&movesBitboard)
            let move = Move(fromSquare: square, targetSquare: targetSquare)
            if !attackedSquares.contains(move.targetSquare!) {
                moves.append(move)
            }
        }
    }
    
}
func generateKnightAttacks(game: Game, square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    var knightBitboard = Bitboard(1) << Bitboard(square)
        let square = Bitboard.popLSB(&knightBitboard)
        let knight = Bitboard(1) << Bitboard(square)
        let movesBitboard = generateKnightAttacks(bitboard: knight) & ~friendlyBitboard
        return movesBitboard
}

func generateKnightMoves(game: Game, square: Int, moves: inout [Move]) {
    var friendlyMask = Bitboard(0)
    var knightBitboard = Bitboard(1) << Bitboard(square)
    if game.currentTurnColor == .white {
        friendlyMask = Magic.whitePiecesBitboards(bitboards: game.bitboards)
    } else {
        friendlyMask = Magic.blackPiecesBitboards(bitboards: game.bitboards)
    }
    
    while knightBitboard != 0 {
        let square = Bitboard.popLSB(&knightBitboard)
        let knight = Bitboard(1) << Bitboard(square)
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
#warning("no en passant yet, no promotion yet")
                    /*
                     for en passant 1. check fen's string if in fly is possible 2. if pawn "jumps" over attacked square by enemy pawn (?)
                     */
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

func generateAllAttackedSquares(game: Game, color: Piece.PieceColor) -> Bitboard {
    var attackBitboard = Bitboard(0)
    let currentColor = game.currentTurnColor
    let friendlyBitboard = currentColor == .black ? Magic.whitePiecesBitboards(bitboards: game.bitboards) : Magic.blackPiecesBitboards(bitboards: game.bitboards)

    for bitboard in game.bitboards {
        if Piece.checkColor(piece: bitboard.key) == color {
            var pieceSquares = [Int]()
            var copyBitboard: Bitboard = bitboard.value
            
            while copyBitboard != 0 {
                pieceSquares.append(Bitboard.popLSB(&copyBitboard))
            }
            let pieceType = Piece.getType(piece: bitboard.key)
            
            for square in pieceSquares {
                switch pieceType {
                case .queen:
                    attackBitboard = attackBitboard | generateQueenAttacks(game: game, square: square, friendlyBitboard: friendlyBitboard)
                    
                case .bishop:
                    attackBitboard = attackBitboard | generateBishopAttacks(game: game, square: square, friendlyBitboard: friendlyBitboard)

                case .rook:
                    attackBitboard = attackBitboard | generateRookAttacks(game: game, square: square, friendlyBitboard: friendlyBitboard)
                case .pawn:
                    attackBitboard = attackBitboard | generatePawnAttacks(game: game, square: square, color: currentColor.getOppositeColor())
                case .king:
                    attackBitboard = attackBitboard | generateKingAttacks(game: game, square: square, friendlyBitboard: friendlyBitboard)
                    
                case .knight:
                    attackBitboard = attackBitboard | generateKnightAttacks(game: game, square: square, friendlyBitboard: friendlyBitboard)
                    
                default:
                    print("not found")
                    
                }
            }
        }
    }
    return attackBitboard
}

func getKingPosition(game: Game, color: Piece.PieceColor) -> Int {
    
    if color == .white {
        var b = game.bitboards[Piece.ColoredPieces.whiteKing.rawValue]!
        let square = Bitboard.popLSB(&b)
        return square
    } else {
        var b = game.bitboards[Piece.ColoredPieces.blackKing.rawValue]!
        let square = Bitboard.popLSB(&b)
        return square
    }
}

func getKingBitboard(game: Game, color: Piece.PieceColor) -> Bitboard {
    
    if color == .white {
        return game.bitboards[Piece.ColoredPieces.whiteKing.rawValue]!
    } else {
        return game.bitboards[Piece.ColoredPieces.blackKing.rawValue]!
    }
    
}

func checkIfCheck(game: Game) -> Bool {
    let attackTable = generateAllAttackedSquares(game: game, color: game.currentTurnColor.getOppositeColor())
    let kingBitboard = getKingBitboard(game: game, color: game.currentTurnColor)
    return (attackTable & kingBitboard) != 0
}

func generateAllLegalMoves(game: Game) -> [Move] {
    var possibleMoves = [Move]()
    var legalMoves = [Move]()
    
    generateAllPossibleMoves(game: game, moves: &possibleMoves)
    
    for move in possibleMoves {
        // Simulate the move on the game state
        var gameCopy = game
        gameCopy.makeMoveOnly(move: move)
        
        
        if !checkIfCheck(game: gameCopy) {
            legalMoves.append(move)
        }
    }

    return legalMoves
}

