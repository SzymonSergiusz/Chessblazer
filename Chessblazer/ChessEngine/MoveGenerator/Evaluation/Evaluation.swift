//
//  Evaluation.swift
//  Chessblazer
//
//  Created by sergiusz on 06/08/2024.
//

import Foundation

let timeLimit: TimeInterval = 3

func isTimeLimitExceeded(searchStartTime: TimeInterval) -> Bool {
    return Date().timeIntervalSince1970 - searchStartTime >= timeLimit
}

let evalPiecesValue: [Piece.ColoredPieces: Int] = [
    .empty : 0,
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


func evaluate(board: [Int]) -> Int {
    return countMaterial(board: board)
}

func alphabeta(game: Game, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool) -> Int {
    var game = game
    var alpha = alpha
    var beta = beta

    if depth == 0 || game.currentValidMoves.isEmpty {
        return evaluate(board: game.toBoardArrayRepresentation())
    }
    let moves = generateAllLegalMoves(game: game).sorted(by: >)

    if maximizingPlayer {
        var maxEval = Int.min
        for move in moves {
            game.makeMove(move: move)
            let eval = alphabeta(game: game, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: false)
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
            let eval = alphabeta(game: game, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: true)
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
    return iterativeDeepening(game: game, initialDepth: depth, maximizingPlayer: maximizingPlayer)
}

func iterativeDeepening(game: Game, initialDepth: Int, maximizingPlayer: Bool) -> Move? {
    var searchStartTime = Date().timeIntervalSince1970
    var bestMove: Move? = nil
    var bestEval = maximizingPlayer ? Int.min : Int.max

    for depth in initialDepth...100 {
        if isTimeLimitExceeded(searchStartTime: searchStartTime) {
            break
        }
        let (move, eval) = performSearch(game: game, depth: depth, maximizingPlayer: maximizingPlayer)
        if maximizingPlayer {
            if eval > bestEval {
                bestEval = eval
                bestMove = move
            }
        } else {
            if eval < bestEval {
                bestEval = eval
                bestMove = move
            }
        }

        print("Depth: \(depth), Best Move: \(String(describing: bestMove?.moveToNotation())), Evaluation: \(bestEval)")
    }

    return bestMove
}

func performSearch(game: Game, depth: Int, maximizingPlayer: Bool) -> (Move?, Int) {
    let legalMoves = generateAllLegalMoves(game: game).sorted(by: >)
    
    
    var bestMove: Move? = nil
    var alpha = Int.min
    var beta = Int.max
    var bestEval = maximizingPlayer ? Int.min : Int.max

    if maximizingPlayer {
        for move in legalMoves {
            var gameCopy = game
            gameCopy.makeMove(move: move)

            let eval = alphabeta(game: gameCopy, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: false)
            gameCopy.undoMove()

            if eval > bestEval {
                bestEval = eval
                bestMove = move
                alpha = max(alpha, bestEval)
            }

            if beta <= alpha {
                break
            }
        }
    } else {
        for move in legalMoves {
            var gameCopy = game
            gameCopy.makeMove(move: move)

            let eval = alphabeta(game: gameCopy, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: true)
            gameCopy.undoMove()

            if eval < bestEval {
                bestEval = eval
                bestMove = move
                beta = min(beta, bestEval)
            }

            if beta <= alpha {
                break
            }
        }
    }

    return (bestMove, bestEval)
}
