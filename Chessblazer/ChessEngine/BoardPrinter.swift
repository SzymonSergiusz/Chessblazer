//
//  BoardTerminalGUI.swift
//  Chessblazer
//
//  Created by sergiusz on 26/07/2024.
//

import Foundation
class BoardPrinter {
    
    func printPossibleMoves(game: Game) {
        let moves = game.generatePseudoLegalMoves(forColor: game.currentTurnColor)
        for move in moves {
            let piece = Piece.ValueToPieceDict[game.board[move.fromSquare!]]
            
            print("\(piece!) :  \(move.moveToNotation())")
        }
    }
    
    func printBoard(board: [Int]) {
        for (index, value) in board.enumerated() {
            if index % 8 == 0 {
                print("")
            }
            if value == 0 {
                print(" \(value)", terminator: " ")
            } else {
                if value / 10 == 0 {
                    print(" \(value)", terminator: " ")
                } else {
                    print("\(value)", terminator: " ")
                }
                
            }
        }
        print()
    }
    
    
    private func printBoardBlackPerspective(board: [Int], emojiMode: Bool = false) {
        let letters = (65...72).map { String(UnicodeScalar($0)!) }
        var numbers = 1
        
        for (index, value) in board.enumerated() {
            if index % 8 == 0 {
                print("")
                print(numbers, terminator: "")
                numbers += 1
            }
            if let pieceChar = emojiMode ? Piece.ValueToPieceEmojiDict[value] : Piece.ValueToPieceDict[value] {
                print(" \(pieceChar)", terminator: " ")
            } else {
                print(" ?", terminator: " ")
            }
            
            
        }
        print()
        for letter in letters {
            print("  \(letter)", terminator: "")
        }
        
        print("")
    }
    
    func printBoard(board: [Int], emojiMode: Bool = false, perspectiveColor: Piece.PieceColor = .white) {
        
        perspectiveColor == .white ? printBoardFromWhitePerspective(board: board, emojiMode: emojiMode) : printBoardBlackPerspective(board: board, emojiMode: emojiMode)
        
    }
    
    private func printBoardFromWhitePerspective(board: [Int], emojiMode: Bool = false) {
        let letters = (65...72).map { String(UnicodeScalar($0)!) }
        var numbers = 8
        
        for row in 0..<8 {
            let startIndex = (7 - row) * 8
            let endIndex = startIndex + 8
            let rowValues = board[startIndex..<endIndex]
            
            print("")
            print(numbers, terminator: "")
            numbers -= 1
            
            for value in rowValues {
                if let pieceChar = emojiMode ? Piece.ValueToPieceEmojiDict[value] : Piece.ValueToPieceDict[value] {
                    print(" \(pieceChar)", terminator: " ")
                } else {
                    print(" ?", terminator: " ")
                }
            }
        }
        
        print()
        for letter in letters {
            print("  \(letter)", terminator: "")
        }
        
        print("")
    }
    func debugPrint(board: [Int]) {
        print()
        for (index, value) in board.enumerated() {
            if index % 8 == 0 && index != 0 {
                print()
            }
            print("\(index):\(value)", terminator: " ")
        }
        print()
    }
}
