//
//  Board.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation
import SwiftUI

struct Game {
    
    init() {
        startNewGame()
    }
    
    var gameProgress = [MoveData]()
    var castlesAvailable: Set<Character> = []
    var enPassant = "-"
    var currentTurnColor: Piece.PieceColor = .white
    /*
     how many moves both players have made since the last pawn advance or piece capture
     when it reaches 100 it should force draw
     */
    var halfMoves = 0
    // when black move
    func getFullMoves() -> Int {
        return halfMoves / 2
    }
    
    var currentValidMoves: [Move] = [Move]()
    
    var bitboards = [Piece.ColoredPieces.RawValue : Bitboard]()
    
    mutating func loadBoardFromFen(fen: String) {
        
        for piece in Piece.ColoredPieces.allCases {
            bitboards[piece.rawValue] = Bitboard(0)
        }
        
        let args = fen.components(separatedBy: " ")
        currentTurnColor = args[1] == "w" ? .white : .black
        castlesAvailable.removeAll()
        for letter in args[2] {
            if letter == "-" { break } else {castlesAvailable.insert(letter)}
        }
        // in fly
        enPassant = args[3]
        
        let ranks: [String] = args[0].components(separatedBy: "/")
        var index = 0
        for rank in ranks.reversed() {
            
            for char in rank {
                if char.isNumber {
                    for _ in 0..<char.wholeNumberValue! {
                        index+=1
                    }
                } else {
                    let piece: Int = Piece.combine(type: Piece.PiecesDict[char.lowercased().first!] ?? Piece.PieceType.empty, color: char.isUppercase ? Piece.PieceColor.white : Piece.PieceColor.black)
                    
                    bitboards[piece] = (bitboards[piece] ?? Bitboard(0)) | (Bitboard(1) << Bitboard(UInt64(index)))
                    
                    index+=1
                    
                }
            }
        }
        
        currentValidMoves = generateAllLegalMoves(game: self)
    }
    
    mutating func startNewGame() {
        loadBoardFromFen(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }
    mutating func makeMoveOperations(pieceValue: Int, from: Int, target: Int) {
        var bitboardsCopy = bitboards
        guard var bitboard = bitboardsCopy[pieceValue] else { return }
        bitboard = bitboard & ~(Bitboard(1) << Bitboard(from))
        bitboard = bitboard | (Bitboard(1) << Bitboard(target))
        bitboardsCopy[pieceValue] = bitboard
        for (key, value) in bitboardsCopy {
            if (key != pieceValue) && (value & (Bitboard(1) << Bitboard(target))) != 0 {
                bitboardsCopy[key] = bitboardsCopy[key]! & ~(Bitboard(1) << Bitboard(target))
                break
            }
        }
        bitboards = bitboardsCopy
    }
    
    mutating func makeMoveOnly(move: Move) {
        guard let from = move.fromSquare else { return }
        guard let target = move.targetSquare else { return }
        let board = toBoardArrayRepresentation()
        let pieceValue = board[from]
        if let castlingMove = move as? CastlingMove {
            makeMoveOperations(pieceValue: board[from], from: from, target: castlingMove.kingDestination)
            makeMoveOperations(pieceValue: board[target], from: target, target: castlingMove.rookDestination)
            
            if board[from] == Piece.ColoredPieces.whiteKing.rawValue {
                castlesAvailable.remove("K")
                castlesAvailable.remove("Q")
            } else if board[from] == Piece.ColoredPieces.blackKing.rawValue {
                castlesAvailable.remove("k")
                castlesAvailable.remove("q")
            }
            
            
        }  else if move.promotionPiece.count > 0 {
            
            guard let newPiece = Piece.ColoredPiecesDict[move.promotionPiece] else { return }
            var bitboardsCopy = bitboards
            guard var newPieceBitboard = bitboardsCopy[newPiece.rawValue] else { return }
            newPieceBitboard = newPieceBitboard | Bitboard(1) << Bitboard(target)
            
            let pawn = board[from]
            guard var pawnBitboard = bitboardsCopy[pawn] else { return }
            pawnBitboard = pawnBitboard & ~(Bitboard(1) << Bitboard(from))
            
            bitboardsCopy[newPiece.rawValue] = newPieceBitboard
            bitboardsCopy[pawn] = pawnBitboard
            
            bitboards = bitboardsCopy
            
        } else {
            makeMoveOperations(pieceValue: pieceValue, from: from, target: target)
            
            switch pieceValue {
            case Piece.ColoredPieces.whiteKing.rawValue:
                castlesAvailable.remove("K")
                castlesAvailable.remove("Q")
                
            case Piece.ColoredPieces.blackKing.rawValue:
                castlesAvailable.remove("k")
                castlesAvailable.remove("q")
                
            case Piece.ColoredPieces.whiteRook.rawValue:
                if from == 0 {
                    castlesAvailable.remove("Q")
                } else if from == 7 {
                    castlesAvailable.remove("K")
                }
            case Piece.ColoredPieces.blackRook.rawValue:
                if from == 56 {
                    castlesAvailable.remove("q")
                } else if from == 63 {
                    castlesAvailable.remove("k")
                }
            default:
                break
            }
        }
    }
    
    mutating func makeMove(move: Move) {
        guard let from = move.fromSquare, let target = move.targetSquare else { return }
        
        let board = toBoardArrayRepresentation()
        let pieceValue = board[from]
        let bitboardsBefore = bitboards
        let castlesAvailableBefore = castlesAvailable
        if currentValidMoves.contains(move) {
            
            if let castlingMove = move as? CastlingMove {
                makeMoveOperations(pieceValue: board[from], from: from, target: castlingMove.kingDestination)
                makeMoveOperations(pieceValue: board[target], from: target, target: castlingMove.rookDestination)
                
                if pieceValue == Piece.ColoredPieces.whiteKing.rawValue {
                    castlesAvailable.remove("K")
                    castlesAvailable.remove("Q")
                } else if pieceValue == Piece.ColoredPieces.blackKing.rawValue {
                    castlesAvailable.remove("k")
                    castlesAvailable.remove("q")
                }
                
            } else if !move.promotionPiece.isEmpty {
                guard let newPiece = Piece.ColoredPiecesDict[move.promotionPiece] else { return }
                
                var bitboardsCopy = bitboards
                
                guard var newPieceBitboard = bitboardsCopy[newPiece.rawValue] else { return }
                newPieceBitboard = newPieceBitboard | (Bitboard(1) << Bitboard(target))
                
                let pawn = board[from]
                guard var pawnBitboard = bitboardsCopy[pawn] else { return }
                pawnBitboard = pawnBitboard & (~(Bitboard(1) << Bitboard(from)))
                
                bitboardsCopy[newPiece.rawValue] = newPieceBitboard
                bitboardsCopy[pawn] = pawnBitboard
                
                bitboards = bitboardsCopy
                
            } else {
                makeMoveOperations(pieceValue: pieceValue, from: from, target: target)
                
                switch pieceValue {
                case Piece.ColoredPieces.whiteKing.rawValue:
                    castlesAvailable.remove("K")
                    castlesAvailable.remove("Q")
                    
                case Piece.ColoredPieces.blackKing.rawValue:
                    castlesAvailable.remove("k")
                    castlesAvailable.remove("q")
                    
                case Piece.ColoredPieces.whiteRook.rawValue:
                    if from == 0 {
                        castlesAvailable.remove("Q")
                    } else if from == 7 {
                        castlesAvailable.remove("K")
                    }
                case Piece.ColoredPieces.blackRook.rawValue:
                    if from == 56 {
                        castlesAvailable.remove("q")
                    } else if from == 63 {
                        castlesAvailable.remove("k")
                    }
                default:
                    break
                }
            }
            
            gameProgress.append(MoveData(
                piece: pieceValue,
                turn: getFullMoves(),
                color: currentTurnColor,
                move: move,
                capturedPiece: toBoardArrayRepresentation()[target] > 0 ? toBoardArrayRepresentation()[target] : nil,
                bitboards: bitboardsBefore,
                castles: castlesAvailableBefore
            ))
            
            toggleColor()
            
            currentValidMoves = generateAllLegalMoves(game: self)
        }
    }
    

    mutating func undoMove() {
        guard let moveData = gameProgress.last else { return }
        let move = moveData.move
        let pieceValue = moveData.piece
        let capturedPiece = moveData.capturedPiece
        
        guard let from = move.fromSquare, let target = move.targetSquare else { return }
        
        
        bitboards = moveData.bitboards
        castlesAvailable = moveData.castles
        gameProgress.removeLast()
        
        toggleColor()
        
        currentValidMoves = generateAllLegalMoves(game: self)
    }

    
    
    mutating func toggleColor() {
        if currentTurnColor == .white {
            currentTurnColor = .black
        } else {
            currentTurnColor = .white
        }
    }
    
    func toBoardArrayRepresentation() -> [Int] {
        var array = Array(repeating: 0, count: 64)
        let copy = bitboards
        
        for bitboard in copy {
            var pieceBitboard = bitboard.value
            while pieceBitboard != 0 {
                let piece = bitboard.key
                let index = Bitboard.popLSB(&pieceBitboard)
                
                array[index] = piece
            }
        }
        return array
    }
    
    private func toBitboardsRepresentation(array: [Int]) -> [Piece.ColoredPieces.RawValue : Bitboard] {
        var bitboards = [Piece.ColoredPieces.RawValue : Bitboard]()
        
        for (index, piece) in array.enumerated() {
            if piece > 0 {
                bitboards[piece] = (bitboards[piece] ?? Bitboard(0)) | (Bitboard(1) << Bitboard(UInt64(index)))
            }
        }
        
        return bitboards
    }
}
