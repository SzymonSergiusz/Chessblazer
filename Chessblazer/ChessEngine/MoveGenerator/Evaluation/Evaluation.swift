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

func evaluate(game: Game) -> Int {
    var eval = countMaterial(board: game.toBoardArrayRepresentation())

    return eval
}

func search(depth: Int, game: Game, alpha: Int, beta: Int) -> Int {
    var alpha = alpha
    var moves = [Move]()
    if depth == 0 {
        return evaluate(game: game)
    }
    generateAllPossibleMoves(game: game, moves: &moves)
    
    if moves.count == 0 {
        #warning("check for checkmate or draw")
        return 0
    }
    var gameCopy = game
    for move in moves {
        
        gameCopy.makeMove(move: move)
        let eval = -search(depth: depth-1, game: game, alpha: -alpha, beta: -beta)
        gameCopy.undoMove()
        
        if eval >= beta {
            return beta
        }
        alpha = max(alpha, eval)
    }
    return alpha
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

/*
Evaluation ideas:
 - use simplified eval func
 - endgame when both players' board value is below smth
 */
