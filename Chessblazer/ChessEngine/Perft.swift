//
//  Perf.swift
//  Chessblazer
//
//  Created by sergiusz on 05/09/2024.
//

import Foundation
import Dispatch

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


func perftParallel(depth: Int) -> Int {
    var game = Game()
    game.startNewGame()
    let queue = DispatchQueue(label: "perft", attributes: .concurrent)
    let group = DispatchGroup()
    var nodeCount = 0
    
    func perft(game: inout Game, depth: Int) -> Int {
        if depth == 0 {
            return 1
        }
        
        let legalMoves = generateAllLegalMoves(game: game)
        var localNodeCount = 0
        
        for move in legalMoves {
            var gameCopy = game
            gameCopy.makeMove(move: move)
            localNodeCount += perft(game: &gameCopy, depth: depth - 1)
        }
        
        return localNodeCount
    }
    
    let legalMoves = generateAllLegalMoves(game: game)

    for move in legalMoves {
        group.enter()
        queue.async {
            var gameCopy = game
            gameCopy.makeMove(move: move)
            let count = perft(game: &gameCopy, depth: depth - 1)
            DispatchQueue.global().sync {
                nodeCount += count
            }
            group.leave()
        }
    }

    group.wait()
    return nodeCount
}


func perftTest1(depth: Int) -> Int {
    var game = Game()
    game.startNewGame()
    func perft(depth: Int, game: inout Game) -> Int {
        var nodeCount = 0

        if depth == 0 {
            return 1
        }

        let legalMoves = game.currentValidMoves

        for move in legalMoves {
            game.makeMove(move: move)
            nodeCount += perft(depth: depth - 1, game: &game)
            game.undoMove()
        }
        return nodeCount
    }
    
    return perft(depth: depth, game: &game)
}
