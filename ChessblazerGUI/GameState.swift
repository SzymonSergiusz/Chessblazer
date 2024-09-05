//
//  GameState.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 03/08/2024.
//

import Foundation

@Observable
class GameState {
    var game = Game()
    var evaluation = 0
    var boardState: [Int] = Array(repeating: 0, count: 64)
    var indexOfTappedPiece: Int = -1
    var tappedPieceTargets = [Int]()
    var attackTable = [Int]()
    var validMoves = [Move]()
    var currentColorToMove = Piece.PieceColor.white
    
    var vsEngine = false
    
    func startNewGame() {
        game = Game()
        boardState.removeAll()
        validMoves.removeAll()
        currentColorToMove = Piece.PieceColor.white
        tappedPieceTargets.removeAll()
        validMoves = game.currentValidMoves
        game.startNewGame()
        boardState = game.toBoardArrayRepresentation()
    }
    func loadFenGame(fen: String) {
        #warning("add validation for fen string here")
        boardState.removeAll()
        validMoves.removeAll()
        tappedPieceTargets.removeAll()
        game.loadBoardFromFen(fen: fen)
        boardState = game.toBoardArrayRepresentation()
        validMoves = game.currentValidMoves
        currentColorToMove = game.currentTurnColor
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
        
        guard let move = validMoves.first(where: {$0 == Move(fromSquare: from, targetSquare: to)}) else { return }
        
        game.makeMove(move: move)
        boardState = game.toBoardArrayRepresentation()
        validMoves = game.currentValidMoves
        currentColorToMove = game.currentTurnColor
        attackTable = generateAllAttackedSquares(game: game, color: currentColorToMove.getOppositeColor())
        print(attackTable)
        
        
        let bp = BoardPrinter()
        bp.printBoard(board: game.toBoardArrayRepresentation(), emojiMode: true, perspectiveColor: .white)
        
        #warning("to refactor, fast check")
        if vsEngine && currentColorToMove == .black {
            let move = validMoves.randomElement()!
            makeMove(move.fromSquare!, move.targetSquare!)
        }
        
        
        evaluation = evaluate(game: game)
    }
    
    func validTargetSquares(fromSquare: Int) -> [Int] {
        var targets = [Int]()
        for move in validMoves where (move.fromSquare != nil && move.targetSquare != nil && move.fromSquare == fromSquare) {
            targets.append(move.targetSquare!)
        }
        return targets
    }
    
    func undoneMove() {
        game.undoMove()
        
        boardState.removeAll()
        validMoves.removeAll()
        currentColorToMove = game.currentTurnColor
        tappedPieceTargets.removeAll()
        validMoves = game.currentValidMoves
        boardState = game.toBoardArrayRepresentation()
        evaluation = evaluate(game: game)
    }
}
