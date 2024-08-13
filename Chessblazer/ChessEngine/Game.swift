//
//  Board.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation
import SwiftUI


class Game {
    
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
    var fullMoves = 0
    
    var isBlackKingChecked = false
    var isWhiteKingChecked = false
    var currentValidMoves = [Move]()
    
    var bitboards = [Piece.ColoredPieces.RawValue : Bitboard]()
    
    func loadBoardFromFen(fen: String) {
        bitboards = [Piece.ColoredPieces.RawValue : Bitboard]()
        
        let args = fen.components(separatedBy: " ")
        currentTurnColor = args[1] == "w" ? .white : .black
#warning("todo possible bug here if game starts with startpos moves ....")
        for letter in args[2] {
            castlesAvailable.removeAll()
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
        generateAllPossibleMoves(game: self, moves: &currentValidMoves)
    }
    
    
    
    func startNewGame() {
        loadBoardFromFen(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }
    
    func makeMove(pieceValue: Int, move: Move) {
        guard let from = move.fromSquare else { return }
        guard let target = move.targetSquare else { return }

        if currentValidMoves.contains(move) {
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

            #warning("add move data")
            
            
            bitboards = bitboardsCopy

            let boardPrinter = BoardPrinter()
            print("Engine board:")
            boardPrinter.printBoard(board: toBoardArrayRepresentation(), emojiMode: true, perspectiveColor: .white)

            toggleColor()
            print("\(currentTurnColor) to move")

            generateAllPossibleMoves(game: self, moves: &currentValidMoves)
        }
    }
    
    func undoneMove() {
        #warning("using move data")

    }
    
    func toggleColor() {
        if currentTurnColor == .white {
            currentTurnColor = .black
        } else {
            currentTurnColor = .white
        }
    }
    
    static let squaresToEdge: [Int: [Int]] = {
        var dict = [Int: [Int]]()
        for file in 0..<8 {
            for rank in 0..<8 {
                let numNorth = 7 - rank
                let numSouth = rank
                let numWest = file
                let numEast = 7 - file
                let indexOfSquare = 8 * rank + file
                
                dict[indexOfSquare] = [
                    numNorth,
                    numSouth,
                    numWest,
                    numEast,
                    min(numNorth, numWest),
                    min(numSouth, numEast),
                    min(numNorth, numEast),
                    min(numSouth, numWest),
                ]
            }
        }
        return dict
    }()
    
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


