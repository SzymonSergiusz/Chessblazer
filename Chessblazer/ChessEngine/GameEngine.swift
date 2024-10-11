//
//  GameEngine.swift
//  Chessblazer
//
//  Created by sergiusz on 11/10/2024.
//

import Foundation

class GameEngine {
    
    static func makeMoveOperations(bitboards: [Int: Bitboard], pieceValue: Int, from: Int, target: Int) -> [Int: Bitboard] {
        var bitboardsCopy = bitboards
        var bitboard = bitboards[pieceValue]! //it's expected to cause exception if something is wrong in code before
        bitboard = bitboard & ~(Bitboard(1) << Bitboard(from))
        bitboard = bitboard | (Bitboard(1) << Bitboard(target))
        bitboardsCopy[pieceValue] = bitboard
        for (key, value) in bitboardsCopy {
            if (key != pieceValue) && (value & (Bitboard(1) << Bitboard(target))) != 0 {
                bitboardsCopy[key] = bitboardsCopy[key]! & ~(Bitboard(1) << Bitboard(target))
                break
            }
        }
        return bitboardsCopy
    }
    
//    static func makeMoveOnly(game: Game, move: Move) {
//        var bitboards = game.bitboards
//        var game = game
//        
//        guard let from = move.fromSquare else { return }
//        guard let target = move.targetSquare else { return }
//        let pieceValue = move.pieceValue
//        
//        if let castlingMove = move as? CastlingMove {
//            bitboards = makeMoveOperations(bitboards: bitboards, pieceValue: pieceValue, from: from, target: castlingMove.kingDestination)
//            bitboards = makeMoveOperations(bitboards: bitboards, pieceValue: move.captureValue, from: target, target: castlingMove.rookDestination)
//            
//            if pieceValue == Piece.ColoredPieces.whiteKing.rawValue {
//                game.boardState.castlesAvailable.remove("K")
//                game.boardState.castlesAvailable.remove("Q")
//            } else if pieceValue == Piece.ColoredPieces.blackKing.rawValue {
//                game.boardState.castlesAvailable.remove("k")
//                game.boardState.castlesAvailable.remove("q")
//            }
//            
//            
//        }  else if move.promotionPiece != 0 {
//            let newPiece = move.promotionPiece
//            var bitboardsCopy = bitboards
//            guard var newPieceBitboard = bitboardsCopy[newPiece] else { return }
//            newPieceBitboard = newPieceBitboard | Bitboard(1) << Bitboard(target)
//            
//            guard var pawnBitboard = bitboardsCopy[pieceValue] else { return }
//            pawnBitboard = pawnBitboard & ~(Bitboard(1) << Bitboard(from))
//            
//            bitboardsCopy[newPiece] = newPieceBitboard
//            bitboardsCopy[pieceValue] = pawnBitboard
//            
//            bitboards = bitboardsCopy
//            
//        } else {
//
//            bitboards = makeMoveOperations(bitboards: bitboards, pieceValue: pieceValue, from: from, target: target)
//            
//            switch pieceValue {
//            case Piece.ColoredPieces.whiteKing.rawValue:
//                game.boardState.castlesAvailable.remove("K")
//                game.boardState.castlesAvailable.remove("Q")
//                
//            case Piece.ColoredPieces.blackKing.rawValue:
//                game.boardState.castlesAvailable.remove("k")
//                game.boardState.castlesAvailable.remove("q")
//                
//            case Piece.ColoredPieces.whiteRook.rawValue:
//                if from == 0 {
//                    game.boardState.castlesAvailable.remove("Q")
//                } else if from == 7 {
//                    game.boardState.castlesAvailable.remove("K")
//                }
//            case Piece.ColoredPieces.blackRook.rawValue:
//                if from == 56 {
//                    game.boardState.castlesAvailable.remove("q")
//                } else if from == 63 {
//                    game.boardState.castlesAvailable.remove("k")
//                }
//            default:
//                break
//            }
//        }
//    }
    
    
}
