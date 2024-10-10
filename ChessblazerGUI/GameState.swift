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
    var currentColorToMove = Piece.Color.white
    
    var vsEngine = false
    
    func startNewGame() {
        game = Game()
        boardState.removeAll()
        validMoves.removeAll()
        currentColorToMove = Piece.Color.white
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
        currentColorToMove = game.boardState.currentTurnColor
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
        self.validMoves = self.game.currentValidMoves
        self.currentColorToMove = game.boardState.currentTurnColor

        
        DispatchQueue.main.async {
            self.boardState = self.game.toBoardArrayRepresentation()
        }
        var bits = generateAllAttackedSquares(bitboards: game.bitboards, currentColor: currentColorToMove.getOppositeColor())
        attackTable.removeAll()
        while bits != 0 {
            let x = UInt64.popLSB(&bits)
            attackTable.append(x)
        }

//        let bp = BoardPrinter()
//        bp.printBoard(board: game.toBoardArrayRepresentation(), emojiMode: true, perspectiveColor: .white)

    }

    func engineMove() async {
        print("engine is starting")
        while !game.boardState.hasGameEnded {
            if vsEngine && currentColorToMove == .black {
                let move = findBestMove(game: game, depth: 3, maximizingPlayer: false)
                if let move = move {
                    makeMove(move.fromSquare!, move.targetSquare!)
                }
            }

//            if vsEngine && currentColorToMove == .white {
//                let move = await findBestMove(game: game, depth: 3, maximizingPlayer: true)
//                if let move = move {
//                    makeMove(move.fromSquare!, move.targetSquare!)
//                }
//            }
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
        currentColorToMove = game.boardState.currentTurnColor
        tappedPieceTargets.removeAll()
        validMoves = game.currentValidMoves
        boardState = game.toBoardArrayRepresentation()
        evaluation = evaluate(bitboards: game.bitboards)
    }
}
