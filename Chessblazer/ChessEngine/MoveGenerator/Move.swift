//
//  Move.swift
//  Chessblazer
//
//  Created by sergiusz on 26/07/2024.
//

import Foundation

class Move: Equatable, Hashable, Comparable, Codable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fromSquare!+targetSquare!+enPasssantCapture)
    }
    
    var castling = false
//    var castlingDestinations: (king: Int, rook: Int) = (0, 0)
    var castlingRookDestination = 0
    var castlingKingDestination = 0
    var fromSquare: Int?
    var targetSquare: Int?
    var promotionPiece: Int = 0
    var enPasssantCapture = 0
    
    var pieceValue: Int = 0
    var captureValue = 0

    var asString: String {
        "\(fromSquare!) \(targetSquare!)"
    }
    
    init(fromSquare: Int, targetSquare: Int, enPasssantCapture: Int, pieceValue: Int, captureValue: Int) {
        self.fromSquare = fromSquare
        self.targetSquare = targetSquare
        self.enPasssantCapture = enPasssantCapture
        self.pieceValue = pieceValue
        self.captureValue = captureValue
    }
    
    init(fromSquare: Int, targetSquare: Int, pieceValue: Int,  captureValue: Int) {
        self.fromSquare = fromSquare
        self.targetSquare = targetSquare
        self.captureValue = captureValue
        self.pieceValue = pieceValue
    }
    
    init(fromSquare: Int, targetSquare: Int, pieceValue: Int,  captureValue: Int, promotionPiece: Int) {
        self.fromSquare = fromSquare
        self.targetSquare = targetSquare
        self.captureValue = captureValue
        self.pieceValue = pieceValue
        self.promotionPiece = promotionPiece
    }
    
    init(fromSquare: Int, targetSquare: Int, kingValue: Int, rookValue: Int, kingDestination: Int, rookDestination: Int) {
        self.castling = true
        self.fromSquare = fromSquare
        self.targetSquare = targetSquare
        self.pieceValue = kingValue
        self.captureValue = rookValue
        self.castlingKingDestination = kingDestination
        self.castlingRookDestination = rookDestination
        
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return (lhs.fromSquare == rhs.fromSquare) && (lhs.targetSquare == rhs.targetSquare)
    }
#warning("think about it")
    func moveValue(attackPawnTable: Bitboard = Bitboard(0)) -> Int {
        var score = 0
        let pieceRealValue = PieceValueTable[pieceValue]!
        let captureRealValue = PieceValueTable[pieceValue]!

        if Piece.getType(piece: captureValue) == .king {
            score += 50
        } else if captureValue != 0 {
            score += abs(captureRealValue) * 10 - abs(pieceRealValue)
        }
        
        if promotionPiece != 0 {
            score += promotionPiece
        }

        let b = (Bitboard(1) << Bitboard(targetSquare!))
        if b & attackPawnTable == b {
            score -= abs(pieceRealValue)
        }
        return score
    }
    
    static func < (lhs: Move, rhs: Move) -> Bool {
        return lhs.moveValue() < rhs.moveValue()
    }
    init(notation: String) {
                
        if notation.count == 4 {
            self.fromSquare = translateFromNotationToSquare(String(notation.prefix(2)))
            self.targetSquare = translateFromNotationToSquare(String(notation.suffix(2)))
        } else {
            self.fromSquare = translateFromNotationToSquare(String(notation.prefix(2)))
            
            let start = notation.index(notation.startIndex, offsetBy: 2)
            let end = notation.index(notation.startIndex, offsetBy: 4)
            self.targetSquare = translateFromNotationToSquare(String(notation[start..<end]))
            if let pp = Piece.ColoredPiecesDict[String(notation.suffix(1))] {
                self.promotionPiece = pp.rawValue
            }
        }
        self.pieceValue = 0
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
    
    var letterToNumber: [String : Int] = [
        "A" : 0,
        "B" : 1,
        "C" : 2,
        "D" : 3,
        "E" : 4,
        "F" : 5,
        "G" : 6,
        "H" : 7,
    ]
    
    func translateFromNotationToSquare(_ notation: String) -> Int? {
        guard notation.count == 2 else { return nil }
        let letter = String(notation.prefix(1))
        guard let fileIndex = letterToNumber[letter.uppercased()] else { return nil }
        guard let rankNumber: Int = Int(String(notation.suffix(1))), rankNumber >= 1, rankNumber <= 8 else { return nil }
        let rankIndex = rankNumber - 1
        return 8 * rankIndex + fileIndex
    }
}
