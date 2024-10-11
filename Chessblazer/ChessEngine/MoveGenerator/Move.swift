//
//  Move.swift
//  Chessblazer
//
//  Created by sergiusz on 26/07/2024.
//

import Foundation

class Move: Equatable, Hashable, Comparable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fromSquare!+targetSquare!)
    }
    
    var castling = false
    var castlingDestinations: (king: Int, rook: Int) = (0, 0)
    var fromSquare: Int?
    var targetSquare: Int?
    var promotionPiece: Int = 0
    var enPasssantCapture = 0
    
    var pieceValue: Int
    var captureValue = 0

    #warning("add logic for this")
    var isAttackedByPawn = false

    var asString: String {
        "\(fromSquare!) \(targetSquare!)"
    }
    
    init(fromSquare: Int, targetSquare: Int, enPasssantCapture: Int, pieceValue: Int) {
        self.fromSquare = fromSquare
        self.targetSquare = targetSquare
        self.enPasssantCapture = enPasssantCapture
        #warning("reconsider this but should be ok for now")
        self.captureValue = Piece.ColoredPieces.whitePawn.rawValue
        self.pieceValue = pieceValue
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
        castlingDestinations.king = kingDestination
        castlingDestinations.rook = rookDestination
        
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return (lhs.fromSquare == rhs.fromSquare) && (lhs.targetSquare == rhs.targetSquare)
    }
    
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
        #warning("lets say promotion is hetman for now")
            score += 900
        }
        //isAttackedByPawn
        let b = (Bitboard(1) << Bitboard(targetSquare!))
        if b & attackPawnTable == b {
            score -= abs(pieceRealValue)
        }
        return score
    }
    
    static func < (lhs: Move, rhs: Move) -> Bool {
        return lhs.moveValue() < rhs.moveValue()
    }
        
//    init(notation: String) {
//        
//        #warning("think about it")
//        
//        if notation.count == 4 {
//            self.fromSquare = Move.translateFromNotationToSquare(String(notation.prefix(2)))
//            self.targetSquare = Move.translateFromNotationToSquare(String(notation.suffix(2)))
//        } else {
//            self.fromSquare = Move.translateFromNotationToSquare(String(notation.prefix(2)))
//            
//            let start = notation.index(notation.startIndex, offsetBy: 2)
//            let end = notation.index(notation.startIndex, offsetBy: 4)
//            self.targetSquare = Move.translateFromNotationToSquare(String(notation[start..<end]))
//            if let pp = Piece.ColoredPiecesDict[String(notation.suffix(1))] {
//                self.promotionPiece = pp.rawValue
//            }
//        }
//    }
    
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
    
    static let letterToNumber: [String : Int] = [
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
