//
//  Move.swift
//  Chessblazer
//
//  Created by sergiusz on 26/07/2024.
//

import Foundation

struct Move: Equatable, Hashable, Comparable, Codable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fromSquare!+targetSquare!+enPasssantCapture)
    }
    
    var castlingRookDestination = 0
    var castlingKingDestination = 0
    var promotionPiece: Int = 0
    var enPasssantCapture = 0
    var pieceValue: Int = 0
    var captureValue = 0
    
    var fromSquare: Int?
    var targetSquare: Int?
    
    
    var castling: Bool { castlingRookDestination != 0 || castlingKingDestination != 0}

    
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

}
