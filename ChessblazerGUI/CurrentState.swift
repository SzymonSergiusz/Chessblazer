//
//  CurrentState.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 02/08/2024.
//

import Foundation


class CurrentState {
    static var moves = [Move]()
    static var positions = [CGPoint]()
    static var game = Game()
    
    static func getMoves(square: Int) {
                
        for move in moves where move.fromSquare == square {
            print(move.moveToNotation())
        }
        
    }
    
    static func validTargetSquares(fromSquare: Int) -> [Int] {
        var targets = [Int]()
        for move in moves where (move.fromSquare != nil && move.targetSquare != nil && move.fromSquare == fromSquare) {
            targets.append(move.targetSquare!)
        }
        return targets
    }
    
    static func createCurrentState(game: Game) {
        generateAllPossibleMoves(game: game, moves: &moves)

    }
    static func afterMove(game: Game) {
        moves.removeAll()
        createCurrentState(game: game)
    }
    
    static func squareToNotation(square: Int) -> String {
        let ranks = square / 8 + 1
        let files = square % 8
        let letters = "abcdefgh"

        guard ranks >= 1 && ranks <= 8 && files >= 0 && files < 8 else {
            return "Invalid square"
        }

        let fileLetter = letters[letters.index(letters.startIndex, offsetBy: files)]
        return "\(fileLetter)\(ranks)"
    }
    
}
