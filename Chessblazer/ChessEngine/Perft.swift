//
//  Perf.swift
//  Chessblazer
//
//  Created by sergiusz on 05/09/2024.
//

import Foundation

struct PerftData : Equatable {
    var captures: Int = 0
    var enPassants: Int = 0
    var castles: Int = 0
    var checks: Int = 0
    var checkmates: Int = 0
    var promotions: Int = 0
    
    static func ==(lhs: PerftData, rhs: PerftData) -> Bool {
        return lhs.captures == rhs.captures
        && lhs.castles == rhs.castles
        && lhs.checks == rhs.checks
        && lhs.checkmates == rhs.checkmates
        && lhs.enPassants == rhs.enPassants
        && lhs.promotions == rhs.promotions
    }
}

// bulk
func perftTest(depth: Int) -> (Int, PerftData) {
    let game = Game()
    var perftData = PerftData()    
    func perft(depth: Int, game: Game) -> Int {
        var nodeCount = 0
        
        if depth == 1 {
            
            for move in game.boardState.currentValidMoves {
                game.makeMove(move: move)
                
                if game.boardState.currentValidMoves.isEmpty && checkIfCheck(boardState: game.boardState) {
                    perftData.checkmates += 1
                }
                
                if checkIfCheck(boardState: game.boardState) {
                    perftData.checks += 1
                }
                
                if move.captureValue != 0 && !move.castling {
                    perftData.captures += 1
                }
                if move.enPasssantCapture != 0 {
                    perftData.enPassants += 1
                }
                if move.castling {
                    perftData.castles += 1
                }
                game.undoMove()
            }
            return game.boardState.currentValidMoves.count
        }
        
        if game.boardData.hasGameEnded {
            return 0
        }
        
        for move in game.boardState.currentValidMoves {
            game.makeMove(move: move)
            
            nodeCount += perft(depth: depth - 1, game: game)
            game.undoMove()
        }
        return nodeCount
    }
    return (perft(depth: depth, game: game), perftData)
}

func perftTest(depth: Int, fen: String) -> (Int, PerftData) {
    var perftData = PerftData()
    let game = Game()
    game.loadFromFen(fen: fen)
    func perft(depth: Int, game: Game) -> Int {
        var nodeCount = 0
        
        if depth == 1 {
            
            if game.boardData.hasGameEnded {
                return 0
            }
            let moves = game.boardState.currentValidMoves

                for move in moves {
                    game.makeMove(move: move)

                    if move.castling {
                        perftData.castles += 1

                    }
                    
                    if game.boardState.currentValidMoves.isEmpty && checkIfCheck(boardState: game.boardState) {
                        perftData.checkmates += 1
                    }
                    
                    if checkIfCheck(boardState: game.boardState) {
                        perftData.checks += 1
                    }
                    
                    if move.promotionPiece != 0 {
                        perftData.promotions += 1
                    }
                    
                    
                    if move.captureValue != 0 && !move.castling {
                        perftData.captures += 1
                    }
                    if move.enPasssantCapture != 0 {
                        perftData.enPassants += 1
                    }
                    game.undoMove()
                }
                return moves.count
        }
        for move in game.boardState.currentValidMoves {
            game.makeMove(move: move)
            
            nodeCount += perft(depth: depth - 1, game: game)
            game.undoMove()
        }
        return nodeCount
    }
    
    return (perft(depth: depth, game: game), perftData)
}

func bulkPerftTest(depth: Int) -> Int {
    bulkPerftTest(depth: depth, fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
}

func bulkPerftTest(depth: Int, fen: String) -> Int {
    let game = Game()
    game.loadFromFen(fen: fen)
    func perft(depth: Int, game: Game) -> Int {
        var nodeCount = 0
        
        if depth == 1 {
            return game.boardState.currentValidMoves.count
        }
        
        if game.boardData.hasGameEnded {
            return 0
        }
        
        for move in game.boardState.currentValidMoves {
            game.makeMove(move: move)
            nodeCount += perft(depth: depth - 1, game: game)
            game.undoMove()
        }
        return nodeCount
    }
    return perft(depth: depth, game: game)
}
