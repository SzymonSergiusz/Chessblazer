//
//  Board.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation
import SwiftUI

class Game {
    
    var boardData = BoardData()
    var boardState = BoardState(currentTurnColor: .white)
    
    init() {
        startNewGame()
    }
    
    func loadFromFen(fen: String) {
        boardState = GameEngine.loadBoardFromFen(fen: fen)
        boardState.currentValidMoves = generateAllLegalMoves(boardState: boardState)
        boardState.attackBitboard = generateAllAttackedSquares(bitboards: boardState.bitboards, currentColor: boardState.currentTurnColor)
    }
    
    func startNewGame() {
        loadFromFen(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }
    
    func makeMove(move: Move) {
        
        boardState.performedMovesList.append(
            MoveData(
                piece: move.pieceValue,
                turn: 0,
                color: boardState.currentTurnColor,
                move: move,
                capturedPiece: move.captureValue,
                bitboards: boardState.bitboards,
                castles: boardState.castlesAvailable,
                currentValidMoves: boardState.currentValidMoves,
                attackBitboard: boardState.attackBitboard
            ))
        
        
        boardState = GameEngine.makeMove(boardState: boardState, move: move)
        boardState.currentTurnColor = boardState.currentTurnColor.getOppositeColor()
        boardState.currentValidMoves = generateAllLegalMoves(boardState: boardState)
        boardState.attackBitboard = generateAllAttackedSquares(bitboards: boardState.bitboards, currentColor: boardState.currentTurnColor)
        
        
        if boardState.currentValidMoves.isEmpty {
            if isWhiteKingChecked(boardState: boardState) {
                boardData.gameResult = .black
            } else if isBlackKingChecked(boardState: boardState) {
                boardData.gameResult = .white
            } else {
                boardData.gameResult = .none
            }
        }
    }
    
    func undoMove() {
        guard let moveData = boardState.performedMovesList.popLast() else { return }
        boardState.bitboards = moveData.bitboards
        boardState.castlesAvailable = moveData.castles
        boardState.currentTurnColor = moveData.color
        boardState.currentValidMoves = moveData.currentValidMoves
        boardState.attackBitboard = moveData.attackBitboard
        
        
        if !boardState.currentValidMoves.isEmpty {
            boardData.hasGameEnded = false
            boardData.gameResult = .none
        }
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
    
    func toBoardArrayRepresentation() -> [Int] {
        var array = Array(repeating: 0, count: 64)
        let copy = boardState.bitboards
        
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
}
