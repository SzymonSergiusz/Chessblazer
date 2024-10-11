//
//  GenerateMoves.swift
//  Chessblazer
//
//  Created by sergiusz on 30/07/2024.
//

import Foundation



func generateAllPossibleMoves(bitboards: [Int: Bitboard], currentColor: Piece.Color, moves: inout [Move], lastMove: Move?, castlesAvailable: Set<Character>) {
    
    moves.removeAll()
    for bitboard in bitboards {
        if Piece.checkColor(piece: bitboard.key) == currentColor {
            var pieceSquares = [Int]()
            var copyBitboard: Bitboard = bitboard.value
            
            while copyBitboard != 0 {
                pieceSquares.append(Bitboard.popLSB(&copyBitboard))
            }
            let pieceType = Piece.getType(piece: bitboard.key)
            
            if let lastMove = lastMove {
                moves.append(contentsOf: enPassantCheck(bitboards: bitboards, lastMove: lastMove))
            }
            
            for square in pieceSquares {
                switch pieceType {
                case .queen:
                    generateQueenMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves)
                case .bishop:
                    generateBishopMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves)
                case .rook:
                    generateRookMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves)
                case .pawn:
                    generatePawnMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves)
                case .king:
                    generateKingMovesBitboard(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves, castlesAvailable: castlesAvailable)
                    
                case .knight:
                    generateKnightMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves)
                    
                default:
                    print("\(pieceType) is not found while generating moves")
                    
                }
            }
        }
    }
}

func generateAllAttackedSquares(bitboards: [Int: Bitboard], currentColor: Piece.Color) -> Bitboard {
    let enemyColor = currentColor.getOppositeColor()
    var attackBitboard = Bitboard(0)
    let friendlyBitboard = currentColor == .black ? Magic.whitePiecesBitboards(bitboards: bitboards) : Magic.blackPiecesBitboards(bitboards: bitboards)
    for bitboard in bitboards {
        if Piece.checkColor(piece: bitboard.key) == enemyColor {
            var pieceSquares = [Int]()
            var copyBitboard: Bitboard = bitboard.value
            
            while copyBitboard != 0 {
                pieceSquares.append(Bitboard.popLSB(&copyBitboard))
            }
            let pieceType = Piece.getType(piece: bitboard.key)
            
            for square in pieceSquares {
                switch pieceType {
                case .queen:
                    attackBitboard = attackBitboard | generateQueenAttacks(bitboards: bitboards, square: square, friendlyBitboard: friendlyBitboard)
                    
                case .bishop:
                    attackBitboard = attackBitboard | generateBishopAttacks(bitboards: bitboards, square: square, friendlyBitboard: friendlyBitboard)
                    
                case .rook:
                    attackBitboard = attackBitboard | generateRookAttacks(bitboards: bitboards, square: square, friendlyBitboard: friendlyBitboard)
                case .pawn:
                    let pawnAttackBitboard = generatePawnAttacks(currentColor: currentColor.getOppositeColor(), square: square)
                    attackBitboard = attackBitboard | pawnAttackBitboard
#warning("another place for that")
//                    game.boardState.pawnAttackBitboard = pawnAttackBitboard
                case .king:
                    attackBitboard = attackBitboard | generateKingAttacks(square: square, friendlyBitboard: friendlyBitboard)
                    
                case .knight:
                    attackBitboard = attackBitboard | generateKnightAttacks(square: square, friendlyBitboard: friendlyBitboard)
                    
                default:
                    print("\(pieceType) is not found while generating attackBitboard")
                    
                }
            }
        }
    }
    return attackBitboard
}


func checkIfCheck(bitboards: [Int: Bitboard], currentColor: Piece.Color) -> Bool {
    let attackTable = generateAllAttackedSquares(bitboards: bitboards, currentColor: currentColor)
    let kingBitboard = getKingBitboard(bitboards: bitboards, color: currentColor)
    return (attackTable & kingBitboard) != 0
}

func generateAllLegalMoves(boardState: BoardState) -> [Move] {
    
    var possibleMoves = [Move]()
    var legalMoves = [Move]()
    let lastMove: Move? = boardState.performedMovesList.last?.move
    generateAllPossibleMoves(bitboards: boardState.bitboards, currentColor: boardState.currentTurnColor, moves: &possibleMoves, lastMove: lastMove, castlesAvailable: boardState.castlesAvailable)

    for move in possibleMoves {
        let newState = GameEngine.makeMoveOnly(boardState: boardState, move: move)
        if !checkIfCheck(bitboards: newState.bitboards, currentColor: newState.currentTurnColor) {
            legalMoves.append(move)
        }
    }
    
    return legalMoves
}




func enPassantCheck(bitboards: [Int: Bitboard], lastMove: Move) -> [Move] {
    var moves = [Move]()
    guard let from = lastMove.fromSquare, let target = lastMove.targetSquare else { return [Move]() }
    
    if lastMove.pieceValue == Piece.ColoredPieces.whitePawn.rawValue {
        if (8...15).contains(from) && (24...31).contains(target) {
            let rank4 = Bitboard(4278190080)
            var blackPawns = bitboards[Piece.ColoredPieces.blackPawn.rawValue]! & rank4
            while (blackPawns != 0) {
                let blackPawn = Bitboard.popLSB(&blackPawns)
                if blackPawn-1 == target || blackPawn+1 == target {
                    moves.append(Move(fromSquare: blackPawn, targetSquare: target - 8, enPasssantCapture: target, pieceValue: Piece.ColoredPieces.whitePawn.rawValue))
                }
            }
        }
    } else if lastMove.pieceValue == Piece.ColoredPieces.blackPawn.rawValue {
        if (48...55).contains(from) && (32...39).contains(target) {
            let rank5 = Bitboard(1095216660480)
            var whitePawns = bitboards[Piece.ColoredPieces.whitePawn.rawValue]! & rank5
            while (whitePawns != 0) {
                let whitePawn = Bitboard.popLSB(&whitePawns)
                if whitePawn-1 == target || whitePawn+1 == target {
                    moves.append(Move(fromSquare: whitePawn, targetSquare: target+8, enPasssantCapture: target, pieceValue: Piece.ColoredPieces.blackPawn.rawValue))
                }
            }
            
        }
    }
    return moves
}

