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
        
        DispatchQueue.main.async {
            self.boardState = self.game.toBoardArrayRepresentation()
            self.validMoves = self.game.currentValidMoves
            self.currentColorToMove = self.game.currentTurnColor
        }
        
        var bits = generateAllAttackedSquares(game: game, color: currentColorToMove.getOppositeColor())
        attackTable.removeAll()
        while bits != 0 {
            let x = UInt64.popLSB(&bits)
            attackTable.append(x)
        }

        let bp = BoardPrinter()
        bp.printBoard(board: game.toBoardArrayRepresentation(), emojiMode: true, perspectiveColor: .white)
       
        DispatchQueue.main.async {
            self.evaluation = evaluate(board: self.game.toBoardArrayRepresentation())
        }
    }

    
    func engines() async {
        print("engine is starting")
        while !game.currentValidMoves.isEmpty {
            if vsEngine && currentColorToMove == .black {
                let move = findBestMove(game: game, depth: 3, maximizingPlayer: false)
                if let move = move {
                    makeMove(move.fromSquare!, move.targetSquare!)
                }
            }

            if vsEngine && currentColorToMove == .white {
                let move = findBestMove(game: game, depth: 3, maximizingPlayer: true)
                if let move = move {
                    makeMove(move.fromSquare!, move.targetSquare!)
                }
            }
        }

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
        evaluation = evaluate(board: game.toBoardArrayRepresentation())
    }
}
