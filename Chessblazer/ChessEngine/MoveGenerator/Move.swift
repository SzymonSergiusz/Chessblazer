//
//  Move.swift
//  Chessblazer
//
//  Created by sergiusz on 26/07/2024.
//

import Foundation

class Move: Equatable {
    var fromSquare: Int?
    var targetSquare: Int?
    var promotionPiece: String = ""
    
    var asString: String {
        "\(fromSquare!) \(targetSquare!)"
    }
    
    
    
    init(fromSquare: Int, targetSquare: Int) {
        self.fromSquare = fromSquare
        self.targetSquare = targetSquare
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return (lhs.fromSquare == rhs.fromSquare) && (lhs.targetSquare == rhs.targetSquare)
    }
    
    
    init(notation: String) {
        // think about it
        
        if notation.count == 4 {
            self.fromSquare = Move.translateFromNotationToSquare(String(notation.prefix(2)))
            self.targetSquare = Move.translateFromNotationToSquare(String(notation.suffix(2)))
        } else {
            self.fromSquare = Move.translateFromNotationToSquare(String(notation.prefix(2)))
            
            let start = notation.index(notation.startIndex, offsetBy: 2)
            let end = notation.index(notation.startIndex, offsetBy: 4)
            self.targetSquare = Move.translateFromNotationToSquare(String(notation[start..<end]))
            self.promotionPiece = String(notation.suffix(1))
        }
    }
    
    func squareToNotation(square: Int) -> String {
        let ranks = square / 8 + 1
        let files = square % 8
        let letters = "abcdefgh"

        guard ranks >= 1 && ranks <= 8 && files >= 0 && files < 8 else {
            return "Invalid square"
        }

        let fileLetter = letters[letters.index(letters.startIndex, offsetBy: files)]
        return "\(fileLetter)\(ranks)"
    }
    
    func moveToNotation() -> String {
        return "\(squareToNotation(square: fromSquare!))\(squareToNotation(square: targetSquare!))"
    }
    
    static var letterToNumber: [String : Int] = [
        "A" : 0,
        "B" : 1,
        "C" : 2,
        "D" : 3,
        "E" : 4,
        "F" : 5,
        "G" : 6,
        "H" : 7,
    ]
    
    static func translateFromNotationToSquare(_ notation: String) -> Int? {
        guard notation.count == 2 else { return nil }
        let letter = String(notation.prefix(1))
        guard let fileIndex = letterToNumber[letter.uppercased()] else { return nil }
        guard let rankNumber: Int = Int(String(notation.suffix(1))), rankNumber >= 1, rankNumber <= 8 else { return nil }
        let rankIndex = rankNumber - 1
        return 8 * rankIndex + fileIndex
    }
}
