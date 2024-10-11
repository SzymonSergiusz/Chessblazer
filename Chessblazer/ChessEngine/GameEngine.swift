//
//  GameEngine.swift
//  Chessblazer
//
//  Created by sergiusz on 11/10/2024.
//

import Foundation

class GameEngine {
    
    static func makeMove(boardState: BoardState, move: Move) -> BoardState {
        let castlesAvailableBefore = boardState.castlesAvailable
        let bitboardsBefore = boardState.bitboards
        
        var boardState = boardState
        var bitboards = boardState.bitboards
        
        let from = move.fromSquare!
        let target = move.targetSquare!
        
        let pieceValue = move.pieceValue
        
        
        if move.castling {
            bitboards = GameEngine.makeMoveOperations(bitboards: bitboards, pieceValue: move.pieceValue, from: from, target: move.castlingDestinations.king)
            bitboards = GameEngine.makeMoveOperations(bitboards: bitboards, pieceValue: move.captureValue, from: target, target: move.castlingDestinations.rook)
            
            if pieceValue == Piece.ColoredPieces.whiteKing.rawValue {
                boardState.castlesAvailable.remove("K")
                boardState.castlesAvailable.remove("Q")
            } else if pieceValue == Piece.ColoredPieces.blackKing.rawValue {
                boardState.castlesAvailable.remove("k")
                boardState.castlesAvailable.remove("q")
            }
            
        } else if move.promotionPiece != 0 {
            
            var newPiece = 0

            if let piece = Piece.ColoredPieces(rawValue: move.promotionPiece)?.rawValue {
                newPiece = piece
            } else {
                newPiece = boardState.currentTurnColor == .white ? Piece.ColoredPieces.whiteQueen.rawValue : Piece.ColoredPieces.blackQueen.rawValue
                
            }
            
            var newPieceBitboard = bitboards[newPiece]!
            newPieceBitboard = newPieceBitboard | (Bitboard(1) << Bitboard(target))
            
            var pawnBitboard = bitboards[pieceValue]!
            pawnBitboard = pawnBitboard & (~(Bitboard(1) << Bitboard(from)))
            
            bitboards[newPiece] = newPieceBitboard
            bitboards[pieceValue] = pawnBitboard
            
            
        } else if move.enPasssantCapture != 0 {
            bitboards = GameEngine.makeMoveOperations(bitboards: bitboards, pieceValue: pieceValue, from: from, target: target)
            let enPassantCapture = move.enPasssantCapture
            let captured = move.captureValue
            bitboards[captured] = bitboards[captured]! & ~Bitboard(1 << enPassantCapture)
        } else {
            bitboards = GameEngine.makeMoveOperations(bitboards: bitboards, pieceValue: move.pieceValue, from: from, target: target)
            
            switch pieceValue {
            case Piece.ColoredPieces.whiteKing.rawValue:
                boardState.castlesAvailable.remove("K")
                boardState.castlesAvailable.remove("Q")
                
            case Piece.ColoredPieces.blackKing.rawValue:
                boardState.castlesAvailable.remove("k")
                boardState.castlesAvailable.remove("q")
                
            case Piece.ColoredPieces.whiteRook.rawValue:
                if from == 0 {
                    boardState.castlesAvailable.remove("Q")
                } else if from == 7 {
                    boardState.castlesAvailable.remove("K")
                }
            case Piece.ColoredPieces.blackRook.rawValue:
                if from == 56 {
                    boardState.castlesAvailable.remove("q")
                } else if from == 63 {
                    boardState.castlesAvailable.remove("k")
                }
            default:
                break
            }
        }
        
        boardState.performedMovesList.append(
            MoveData(
                piece: pieceValue,
                turn: 0,
                color: boardState.currentTurnColor,
                move: move,
                capturedPiece: move.captureValue,
                bitboards: bitboardsBefore,
                castles: castlesAvailableBefore,
                currentValidMoves: boardState.currentValidMoves
            ))
        
        
        boardState.bitboards = bitboards
//        boardState.currentTurnColor = boardState.currentTurnColor.getOppositeColor()
//        boardState.currentValidMoves = generateAllLegalMoves(boardState: boardState)
        
        
        
        return boardState
    }
    
    
    
    static func makeMoveOnly(boardState: BoardState, move: Move) -> BoardState {
        var boardState = boardState
        let from = move.fromSquare!
        let target = move.targetSquare!
        let pieceValue = move.pieceValue
        if move.castling {
            boardState.bitboards = GameEngine.makeMoveOperations(bitboards: boardState.bitboards, pieceValue: pieceValue, from: from, target: move.castlingDestinations.king)
            boardState.bitboards = GameEngine.makeMoveOperations(bitboards: boardState.bitboards, pieceValue: move.captureValue, from: target, target: move.castlingDestinations.rook)
            
            if pieceValue == Piece.ColoredPieces.whiteKing.rawValue {
                boardState.castlesAvailable.remove("K")
                boardState.castlesAvailable.remove("Q")
            } else if pieceValue == Piece.ColoredPieces.blackKing.rawValue {
                boardState.castlesAvailable.remove("k")
                boardState.castlesAvailable.remove("q")
            }
        }  else if move.promotionPiece != 0 {
            let newPiece = move.promotionPiece
            var bitboardsCopy = boardState.bitboards
            var newPieceBitboard = bitboardsCopy[newPiece]!
            newPieceBitboard = newPieceBitboard | Bitboard(1) << Bitboard(target)
            
            var pawnBitboard = bitboardsCopy[pieceValue]!
            pawnBitboard = pawnBitboard & ~(Bitboard(1) << Bitboard(from))
            
            bitboardsCopy[newPiece] = newPieceBitboard
            bitboardsCopy[pieceValue] = pawnBitboard
            
            boardState.bitboards = bitboardsCopy
            
        } else {
            
            boardState.bitboards = GameEngine.makeMoveOperations(bitboards: boardState.bitboards, pieceValue: pieceValue, from: from, target: target)
            
            switch pieceValue {
            case Piece.ColoredPieces.whiteKing.rawValue:
                boardState.castlesAvailable.remove("K")
                boardState.castlesAvailable.remove("Q")
                
            case Piece.ColoredPieces.blackKing.rawValue:
                boardState.castlesAvailable.remove("k")
                boardState.castlesAvailable.remove("q")
                
            case Piece.ColoredPieces.whiteRook.rawValue:
                if from == 0 {
                    boardState.castlesAvailable.remove("Q")
                } else if from == 7 {
                    boardState.castlesAvailable.remove("K")
                }
            case Piece.ColoredPieces.blackRook.rawValue:
                if from == 56 {
                    boardState.castlesAvailable.remove("q")
                } else if from == 63 {
                    boardState.castlesAvailable.remove("k")
                }
            default:
                break
            }
        }
        return boardState
    }
    
    static func loadBoardFromFen(fen: String) -> BoardState {
        var boardState = BoardState(currentTurnColor: .white)
        let args = fen.components(separatedBy: " ")
        boardState.currentTurnColor = args[1] == "w" ? .white : .black
        boardState.castlesAvailable.removeAll()
        for letter in args[2] {
            if letter == "-" { break } else {boardState.castlesAvailable.insert(letter)}
        }
        boardState.enPassant = args[3]
        let ranks: [String] = args[0].components(separatedBy: "/")
        var index = 0
        for rank in ranks.reversed() {
            
            for char in rank {
                if char.isNumber {
                    for _ in 0..<char.wholeNumberValue! {
                        index+=1
                    }
                } else {
                    let piece: Int = Piece.combine(type: Piece.PiecesDict[char.lowercased().first!] ?? Piece.PieceType.empty, color: char.isUppercase ? Piece.Color.white : Piece.Color.black)
                    
                    boardState.bitboards[piece] = (boardState.bitboards[piece] ?? Bitboard(0)) | (Bitboard(1) << Bitboard(UInt64(index)))
                    index+=1
                }
            }
        }
        return boardState
    }
    
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
}
