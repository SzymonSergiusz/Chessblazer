//
//  Evaluation.swift
//  Chessblazer
//
//  Created by sergiusz on 06/08/2024.
//

import Foundation

let evalPiecesValue: [Piece.ColoredPieces: Int] = [
    .whitePawn : 100,
    .whiteKnight : 320,
    .whiteBishop : 330,
    .whiteRook : 500,
    .whiteQueen : 900,
    .whiteKing : 20000,
    
    .blackPawn : -100,
    .blackKnight : -320,
    .blackBishop : -330,
    .blackRook : -500,
    .blackQueen : -900,
    .blackKing : -20000,
]

func evaluate(board: [Int]) -> Int {
    return countMaterial(board: board)
}

func alphabeta(game: Game, moves: [Move], depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool) -> Int {
    var game = game
    var alpha = alpha
    var beta = beta

    if depth == 0 || moves.isEmpty {
        return evaluate(board: game.toBoardArrayRepresentation())
    }
    
    if maximizingPlayer {
        var maxEval = Int.min
        
        for move in moves {
            game.makeMove(move: move)
            let eval = alphabeta(game: game, moves: game.currentValidMoves, depth: depth-1, alpha: alpha, beta: beta, maximizingPlayer: false)
            game.undoMove()
            
            maxEval = max(maxEval, eval)
            alpha = max(alpha, maxEval)
            
            if beta <= alpha {
                break
            }
        }
        return maxEval
        
    } else {
        var minEval = Int.max
        
        for move in moves {
            game.makeMove(move: move)
            let eval = alphabeta(game: game, moves: game.currentValidMoves, depth: depth-1, alpha: alpha, beta: beta, maximizingPlayer: true)
            game.undoMove()
            
            minEval = min(minEval, eval)
            beta = min(beta, minEval)
            
            if beta <= alpha {
                break
            }
        }
        return minEval
    }
}
func findBestMove(game: Game, depth: Int, maximizingPlayer: Bool) -> Move? {
    let legalMoves = generateAllLegalMoves(game: game)
    var bestMove: Move? = nil
    
    var alpha = Int.min
    var beta = Int.max
    
    if maximizingPlayer {
        var maxEval = Int.min
        
        for move in legalMoves {
            var gameCopy = game
            gameCopy.makeMove(move: move)
            
            let eval = alphabeta(game: gameCopy, moves: gameCopy.currentValidMoves, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: false)
            
            if eval > maxEval {
                maxEval = eval
                bestMove = move
            }
            
            alpha = max(alpha, maxEval)
        }
    } else {
        var minEval = Int.max
        
        for move in legalMoves {
            var gameCopy = game
            gameCopy.makeMove(move: move)
            
            let eval = alphabeta(game: gameCopy, moves: gameCopy.currentValidMoves, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: true)
            
            if eval < minEval {
                minEval = eval
                bestMove = move
            }
            
            beta = min(beta, minEval)
        }
    }
    
    return bestMove
}



func countMaterial(board: [Int]) -> Int {
    var whiteSum = 0
    var blackSum = 0
    for (index, piece) in board.enumerated() where piece > 0 {
        let coloredPiece = Piece.ColoredPieces(rawValue: piece)!
        let pieceValue = evalPiecesValue[coloredPiece]!
        let positionValue = PieceSquareTables.tables[coloredPiece]![index]
        if Piece.checkColor(piece: coloredPiece.rawValue) == .white {
            whiteSum += pieceValue + positionValue

        } else {
            blackSum += pieceValue - positionValue

        }
    }
    return whiteSum + blackSum
}
