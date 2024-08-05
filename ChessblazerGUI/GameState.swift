//
//  GameState.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 03/08/2024.
//

import Foundation

@Observable
class GameState {
    let game = Game()
    
    var boardState: [Int] = Array(repeating: 0, count: 64)
    var indexOfTappedPiece: Int = -1
    var tappedPieceTargets = [Int]()
    
    var validMoves = [Move]()
    var currentColorToMove = Piece.PieceColor.white
    
    func startNewGame() {
        boardState.removeAll()
        validMoves.removeAll()
        currentColorToMove = Piece.PieceColor.white
        tappedPieceTargets.removeAll()
        validMoves = game.currentValidMoves
        game.startNewGame()
        boardState = game.toBoardArrayRepresentation()
    }
    
    func onPieceTap(square: Int) {
        if tappedPieceTargets.contains(square) {
            if currentColorToMove == Piece.checkColor(piece: boardState[indexOfTappedPiece]) {
                makeMove(indexOfTappedPiece, square)
            }
            tappedPieceTargets.removeAll()
        } else {
            indexOfTappedPiece = square
            tappedPieceTargets = validTargetSquares(fromSquare: square)
        }
}

    func makeMove(_ from: Int, _ to: Int) {
        tappedPieceTargets.removeAll()
        game.makeMove(pieceValue: boardState[from], move: Move(fromSquare: from, targetSquare: to))
        boardState = game.toBoardArrayRepresentation()
        validMoves = game.currentValidMoves
        currentColorToMove = game.currentTurnColor
        
        let bp = BoardPrinter()
        bp.printBoard(board: game.toBoardArrayRepresentation(), emojiMode: true, perspectiveColor: .white)
    }
    
    func validTargetSquares(fromSquare: Int) -> [Int] {
        var targets = [Int]()
        for move in validMoves where (move.fromSquare != nil && move.targetSquare != nil && move.fromSquare == fromSquare) {
            targets.append(move.targetSquare!)
        }
        return targets
    }
}
