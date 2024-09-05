//
//  Perf.swift
//  Chessblazer
//
//  Created by sergiusz on 05/09/2024.
//

import Foundation

func perftTest(depth: Int) -> Int {
    var game = Game()
    game.startNewGame()
    func perft(depth: Int, game: inout Game) -> Int {
        var nodeCount = 0

        if depth == 0 {
            return 1
        }

        let legalMoves = generateAllLegalMoves(game: game)

        for move in legalMoves {
            game.makeMove(move: move)
            nodeCount += perft(depth: depth - 1, game: &game)
            game.undoMove()
        }
        return nodeCount
    }
    
    return perft(depth: depth, game: &game)
}

