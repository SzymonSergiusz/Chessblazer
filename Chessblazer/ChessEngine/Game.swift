//
//  Board.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation
class Game {
    
    var board: [Int] = Array(repeating: 0, count: 64)
    var castlesAvailable: Set<Character> = []
    var enPassant = "-"
    var colorTurn: Piece.PieceColor = .white
    /*
    how many moves both players have made since the last pawn advance or piece capture
    when it reaches 100 it should force draw
    */
    var halfMoves = 0
    // when black move
    var fullMoves = 0
    
    func loadBoardFromFen(fen: String) {
        // regex for fen
        if false {
            return
        }
        
        let args = fen.components(separatedBy: " ")
        colorTurn = args[1] == "w" ? .white : .black
        
        for letter in args[2] {
            castlesAvailable.removeAll()
            if letter == "-" { break } else {castlesAvailable.insert(letter)}
        }
        //w przelocie
        let enPassant = args[3]
        
        let ranks: [String] = args[0].components(separatedBy: "/")
        var index = 0
        for rank in ranks {

            for char in rank {
                if char.isNumber {
                    for _ in 0..<char.wholeNumberValue! {
                        board[index] = 0 //empty
                        index+=1
                    }
                } else {
                    let piece: Int = Piece.combine(type: Piece.PiecesDict[char.lowercased().first!] ?? Piece.PieceType.empty, color: char.isUppercase ? Piece.PieceColor.white : Piece.PieceColor.black)
                    board[index] = piece
                    index+=1
                }
            }
        }
    }
    
    func printBoard() {
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
    
    func printBoard(emojiMode: Bool) {
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
    

}

