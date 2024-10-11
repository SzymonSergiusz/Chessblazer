//
//  Perf.swift
//  Chessblazer
//
//  Created by sergiusz on 05/09/2024.
//

import Foundation

// bulk
func perftTest(depth: Int) -> Int {
    var game = Game()
    
    func perft(depth: Int, game: Game) -> Int {
        var nodeCount = 0

        if depth == 1 {
            return game.boardState.currentValidMoves.count
        }

//        let legalMoves = game.boardState.currentValidMoves

        for move in game.boardState.currentValidMoves {
            game.makeMove(move: move)
            nodeCount += perft(depth: depth - 1, game: game)
            game.undoMove()
        }
        return nodeCount
    }
    return perft(depth: depth, game: game)
}
