//
//  Perf.swift
//  Chessblazer
//
//  Created by sergiusz on 05/09/2024.
//

import Foundation

// bulk

func perftTest(depth: Int) -> (Int, PerftData) {
    let game = Game()
    var perftData = PerftData()
    let bp = BoardPrinter()
    
    func perft(depth: Int, game: Game) -> Int {
        var nodeCount = 0
        
        if depth == 1 {
            
            // another idea is to add into move struct info about type of move and then resolve it here
            
            for move in game.boardState.currentValidMoves {
                
//                if move.castling {
//                    if move.moveToNotation() != "e1a1" || move.moveToNotation() != "e1h1" || move.moveToNotation() != "e8a8" || move.moveToNotation() != "e8h8" {
//                        print("BEFORE")
//                        bp.printBoard(board: game.toBoardArrayRepresentation())
//                    }
//                    
//                }
                
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
//                    if move.moveToNotation() != "e1a1" || move.moveToNotation() != "e1h1" || move.moveToNotation() != "e8a8" || move.moveToNotation() != "e8h8" {
//                        print("AFTER")
//                        bp.printBoard(board: game.toBoardArrayRepresentation())
//                        print("NOTATION:, ", move.moveToNotation())
//                        print("____________________________________")
//                    }
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

func perftTest(depth: Int, game: inout Game) -> (Int, PerftData) {
    var perftData = PerftData()
//    var checkedPositions = Set<[Int]>()
//    let bp = BoardPrinter()
    
    func perft(depth: Int, game: Game) -> Int {
        var nodeCount = 0
        
        if depth == 1 {
            
            if game.boardData.hasGameEnded {
                return 0
            }
            
            // another idea is to add into move struct info about type of move and then resolve it here
            //            print(game.boardState.castlesAvailable)
            let moves = game.boardState.currentValidMoves
            
            
//            if !checkedPositions.contains(game.toBoardArrayRepresentation()) {
//                checkedPositions.insert(game.toBoardArrayRepresentation())

                for move in moves {
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
//                }
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
    let game = Game()
    
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
