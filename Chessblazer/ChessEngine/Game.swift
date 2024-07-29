//
//  Board.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation
// find better naming
class Game {
    
    init() {
        startNewGame()
    }
    
    var board: [Int] = Array(repeating: 0, count: 64)
    var castlesAvailable: Set<Character> = []
    var enPassant = "-"
    var currentTurnColor: Piece.PieceColor = .white
    /*
     how many moves both players have made since the last pawn advance or piece capture
     when it reaches 100 it should force draw
     */
    var halfMoves = 0
    // when black move
    var fullMoves = 0
    
    var isBlackKingChecked = false
    var isWhiteKingChecked = false
    
    func loadBoardFromFen(fen: String) {
        
        let args = fen.components(separatedBy: " ")
        currentTurnColor = args[1] == "w" ? .white : .black
        
        for letter in args[2] {
            castlesAvailable.removeAll()
            if letter == "-" { break } else {castlesAvailable.insert(letter)}
        }
        // in fly
        enPassant = args[3]
        
        let ranks: [String] = args[0].components(separatedBy: "/")
        var index = 0
        for rank in ranks.reversed() {
            
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
    
    func startNewGame() {
        loadBoardFromFen(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }
    
    // todo
    func generateLegalMoves(forColor color: Piece.PieceColor) -> [Move] {
        let pseudoMoves = generatePseudoLegalMoves(forColor: color)
        var legalMoves = [Move]()
        for move in pseudoMoves {
            var newBoardAfterMove = board
            makeMove(board: &newBoardAfterMove, move: move)
            if !checkIfCheck(board: newBoardAfterMove) {
                legalMoves.append(move)
            }
        }
        
        return legalMoves
    }
    
    func generatePseudoLegalMoves(forColor color: Piece.PieceColor) -> [Move] {
        var moves = [Move]()
        for (fromSquare, piece) in board.enumerated() {
            if Piece.checkColor(piece: piece) == color {
                if Piece.isSliding(piece: piece) {
                    generateSlidingMoves(moves: &moves, piece: piece, fromSquare: fromSquare)
                } else if Piece.isLeaping(piece: piece) {
                    generateLeapingMoves(moves: &moves, piece: piece, fromSquare: fromSquare)
                }
            }
        }
        return moves
    }
    
    func checkIfCheck(board: [Int]) -> Bool {
        guard let whiteKingsPosition = board.firstIndex(of: 9),
              let blackKingsPosition = board.firstIndex(of: 17) else {
            return false
        }
        
        let possibleMoves = generatePseudoLegalMoves(forColor: currentTurnColor)
        
        for move in possibleMoves {
            if move.targetSquare == whiteKingsPosition && board[move.fromSquare!] < 16 {
                return true
            }
            if move.targetSquare == blackKingsPosition && board[move.fromSquare!] > 16 {
                return true
            }
        }
        
        return false
    }
    
    static let directionOffsets = [8, -8, -1, 1, 7, -7, 9, -9]
    
    private func generateSlidingMoves(moves: inout [Move], piece: Int, fromSquare: Int) {
        let start = Piece.isType(piece: piece, typeToCheck: .bishop) ? 4 : 0
        let end = Piece.isType(piece: piece, typeToCheck: .rook) ? 4 : 8
        
        for direction in start..<end {
            for j in 0..<Game.squaresToEdge[fromSquare]![direction] {
                let targetSquare = fromSquare + Game.directionOffsets[direction] * (j+1)
                
                if board[targetSquare] != 0 {
                    if (Piece.checkColor(piece: piece) == Piece.checkColor(piece: board[targetSquare])) {
                        break;
                        
                    }
                    moves.append(Move(fromSquare: fromSquare, targetSquare: targetSquare))
                    
                    if (Piece.checkColor(piece: piece) != Piece.checkColor(piece: board[targetSquare])) {
                        break;
                    }
                } else {
                    moves.append(Move(fromSquare: fromSquare, targetSquare: targetSquare))
                }
            }
        }
    }
    
    private func generateLeapingMoves(moves: inout [Move], piece: Int, fromSquare: Int) {
        if Piece.isType(piece: piece, typeToCheck: .pawn) {
            let moveValue = Piece.checkColor(piece: piece) == .white ? 8 : -8
            let targetSquare = fromSquare + moveValue
            
            if board[targetSquare] == 0 {
                moves.append(Move(fromSquare: fromSquare, targetSquare: targetSquare))
                if (8...15).contains(fromSquare) || (48...55).contains(fromSquare) {
                    let firstPawnMove = fromSquare + 2 * moveValue
                    if board[firstPawnMove] == 0 {
                        moves.append(Move(fromSquare: fromSquare, targetSquare: firstPawnMove))
                    }
                }
            }
            
            let attackOffsets = Piece.checkColor(piece: piece) == .white ? [7, 9] : [-7, -9]
            for offset in attackOffsets {
                let attackSquare = fromSquare + offset
                if (0...63).contains(attackSquare) {
                    if board[attackSquare] != 0 && Piece.areOppositeColors(piece1: board[attackSquare], piece2: piece) {
                        moves.append(Move(fromSquare: fromSquare, targetSquare: attackSquare))
                    }
                }
            }
            
            if let enPassantSquare = Move.translateFromNotationToSquare(enPassant),
               //   attackOffsets.contains(enPassantSquare - fromSquare)
               attackOffsets.contains(enPassantSquare)
            {
                moves.append(Move(fromSquare: fromSquare, targetSquare: enPassantSquare))
            }
            
            if (0...7).contains(targetSquare) || (56...63).contains(targetSquare) {
                // todo Promotion
                print("promocja")
            }
        } else if Piece.isType(piece: piece, typeToCheck: .knight) {
            let knightMoves = [10, -10, 6, -6, 15, -15, 17, -17]
            for offset in knightMoves {
                let targetSquare = fromSquare + offset
                if (0...63).contains(targetSquare) {
                    if board[targetSquare] == 0 || Piece.areOppositeColors(piece1: piece, piece2: board[targetSquare]) {
                        moves.append(Move(fromSquare: fromSquare, targetSquare: targetSquare))
                    }
                }
            }
        } else if Piece.isType(piece: piece, typeToCheck: .king) {
            let kingMoves = [1, -1, 8, -8, 7, -7, 9, -9]
            for offset in kingMoves {
                let targetSquare = fromSquare + offset
                if (0...63).contains(targetSquare) {
                    if board[targetSquare] == 0 || Piece.areOppositeColors(piece1: piece, piece2: board[targetSquare]) {
                        moves.append(Move(fromSquare: fromSquare, targetSquare: targetSquare))
                    }
                }
            }
        }
    }
    
    func makeMove(board: inout [Int], move: Move) {
        guard let from = move.fromSquare else { return }
        guard let target = move.targetSquare else { return }
        
        board[target] = board[from]
        board[from] = 0
        
        toggleColor()
    }
    
    func toggleColor() {
        if currentTurnColor == .white {
            currentTurnColor = .black
        } else {
            currentTurnColor = .white
        }
    }
    
    static let squaresToEdge: [Int: [Int]] = {
        var dict = [Int: [Int]]()
        for file in 0..<8 {
            for rank in 0..<8 {
                let numNorth = 7 - rank
                let numSouth = rank
                let numWest = file
                let numEast = 7 - file
                let indexOfSquare = 8 * rank + file
                
                dict[indexOfSquare] = [
                    numNorth,
                    numSouth,
                    numWest,
                    numEast,
                    min(numNorth, numWest),
                    min(numSouth, numEast),
                    min(numNorth, numEast),
                    min(numSouth, numWest),
                ]
            }
        }
        return dict
    }()
}

