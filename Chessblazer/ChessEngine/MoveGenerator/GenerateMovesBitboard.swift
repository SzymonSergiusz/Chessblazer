//
//  GenerateMovesBitboard.swift
//  Chessblazer
//
//  Created by sergiusz on 30/07/2024.
//

import Foundation

func generateKnightAttacks(bitboard: Bitboard) -> Bitboard {
    let knightAttackBitboard: Bitboard =
        ((bitboard << 6) | (bitboard >> 10)) & ~Bitboard.Masks.fileGH |
        ((bitboard << 10) | (bitboard >> 6)) & ~Bitboard.Masks.fileAB |
        ((bitboard << 15) | (bitboard >> 17)) & ~Bitboard.Masks.fileH |
        ((bitboard << 17) | (bitboard >> 15)) & ~Bitboard.Masks.fileA
    
    return knightAttackBitboard
}

// # Pawns moves#
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
func generateAllAttackedSquares(game: Game, color: Piece.PieceColor) -> [Int] {
    var toggledColorGame = game
    toggledColorGame.toggleColor()
    // this is cause of in function checking if piece is enemy or friendly, todo refactor this but toggling color should be enough for now
    
    var attackedSquares = [Int]()
    var attackedSquaresMoves = [Move]()
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
                    generateQueenMoves(game: toggledColorGame, square: square, moves: &attackedSquaresMoves)
                
                case .bishop:
                    generateBishopMoves(game: toggledColorGame, square: square, moves: &attackedSquaresMoves)
                    
                case .rook:
                    generateRookMoves(game: toggledColorGame, square: square, moves: &attackedSquaresMoves)
                case .pawn:
                    #warning("no en passant yet, no promotion yet")
                    /*
                     for en passant 1. check fen's string if in fly is possible 2. if pawn "jumps" over attacked square by enemy pawn (?)
                     */
                    generatePawnAttacks(game: game, square: square, moves: &attackedSquaresMoves)
                case .king:
                    generateKingMoves(game: toggledColorGame, square: square, moves: &attackedSquaresMoves)
                    
                case .knight:
                    generateKnightMoves(game: toggledColorGame, square: square, moves: &attackedSquaresMoves)

                default:
                    print("not found")
                    
                }
            }
        }
    }
    
    for move in attackedSquaresMoves {
        attackedSquares.append(move.targetSquare!)
    }
    return attackedSquares
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

func checkIfCheck(game: Game) -> Bool {
    let attackTable = generateAllAttackedSquares(game: game, color: game.currentTurnColor.getOppositeColor())
    
    
    let kingPosition = getKingPosition(game: game, color: game.currentTurnColor)
    return attackTable.contains(kingPosition)
}

func generateAllLegalMoves(game: Game) -> [Move] {
    var moves = [Move]()
    var legalMoves = [Move]()
    generateAllPossibleMoves(game: game, moves: &moves)
//    print("king's checked")
    
    // to avoid check
    if checkIfCheck(game: game) {
        for move in moves {
            var gameCopy = game
            gameCopy.makeMoveOnly(move: move)
            if checkIfCheck(game: gameCopy) {
//                print("still check")
            } else {
                legalMoves.append(move)
            }
        }
    }
    // xrays
    for move in moves {
        var gameCopy = game
        gameCopy.makeMoveOnly(move: move)
        if checkIfCheck(game: gameCopy) {
//            print("check")
        } else {
            legalMoves.append(move)
        }
    }
    
    
    
    return Array(Set(legalMoves))
}
