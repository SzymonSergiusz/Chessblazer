//
//  Board.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation
// find better naming
class Game {
    
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
    
    func loadBoardFromFen(fen: String) {
        
        let args = fen.components(separatedBy: " ")
        currentTurnColor = args[1] == "w" ? .white : .black
        
        for letter in args[2] {
            castlesAvailable.removeAll()
            if letter == "-" { break } else {castlesAvailable.insert(letter)}
        }
        // in fly
        let enPassant = args[3]
        
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
    
    func isSliding(piece: Int) -> Bool {
        return Piece.isType(piece: piece, typeToCheck: .bishop) || Piece.isType(piece: piece, typeToCheck: .queen) || Piece.isType(piece: piece, typeToCheck: .rook)
    }
    
    func isLeaping(piece: Int) -> Bool {
        return Piece.isType(piece: piece, typeToCheck: .pawn) || Piece.isType(piece: piece, typeToCheck: .knight) || Piece.isType(piece: piece, typeToCheck: .king)
    }
    
    func generateMoves() -> [Move] {
        var moves = [Move]()
        for (fromSquare, piece) in board.enumerated() {
            if true/*checkColor(piece: piece) == currentTurnColor*/ {
                
                
                
                if isSliding(piece: piece) {
                    
                    generateSlidingMoves(moves: &moves, piece: piece, fromSquare: fromSquare)
                } else if isLeaping(piece: piece) {
                    generateLeapingMoves(moves: &moves, piece: piece, fromSquare: fromSquare)
                    
                }
            }
        }
        return moves
    }
    
    private func generateSlidingMoves(moves: inout [Move], piece: Int, fromSquare: Int) {
        let start = Piece.isType(piece: piece, typeToCheck: .bishop) ? 4 : 0
        let end = Piece.isType(piece: piece, typeToCheck: .rook) ? 4 : 8
        
        for direction in start..<end {
            for j in 0..<Game.squaresToEdge[fromSquare]![direction] {
                let targetSquare = fromSquare + Game.directionOffsets[direction] * (j+1)
                
                if board[targetSquare] != 0 {
                    if (Piece.checkColor(piece: piece) == Piece.checkColor(piece: board[targetSquare])) {
                        //                        print("move not found")
                        
                        break;
                        
                    }
                    moves.append(Move(fromSquare: fromSquare, targetSquare: targetSquare))
                    //                    print("move found")
                    if (Piece.checkColor(piece: piece) != Piece.checkColor(piece: board[targetSquare])) {
                        break;
                    }
                } else {
                    moves.append(Move(fromSquare: fromSquare, targetSquare: targetSquare))
                    //                    print("move found")
                    
                }
                
                
            }
        }
    }
    
    private func generateLeapingMoves(moves: inout [Move], piece: Int, fromSquare: Int) {
        
        if Piece.isType(piece: piece, typeToCheck: .pawn) {
            print("pawn")
            var targetSquare: Int = -1
            let moveValue = Piece.checkColor(piece: piece) == .white ? 8 : -8
            targetSquare = fromSquare + moveValue
            
            // czy może zbić
            let attackValue: [Int] = Piece.checkColor(piece: piece) == .white ? [7, 9] : [-7, -9]
            for attack in attackValue {
                let attackSquare = fromSquare+attack
                if (0...63).contains(attackSquare) {
                    if board[attackSquare] != 0 && Piece.areOppositeColors(piece1: board[attackSquare], piece2: piece) {
                        moves.append(Move(fromSquare: fromSquare, targetSquare: attackSquare))
                    }
                }
            }
            
            if (0...7).contains(piece) || (56...63).contains(piece) {
                print("promotion cnie")
                //todo
                return
            }
            
            if board[targetSquare] != 0 {
                return
            }
            
            if (8...15).contains(fromSquare) {
                let firstPawnMove = fromSquare + 2*moveValue
                if board[firstPawnMove] == 0 {
                    moves.append(Move(fromSquare: fromSquare, targetSquare: firstPawnMove))
                }
            }
            moves.append(Move(fromSquare: fromSquare, targetSquare: targetSquare))
            
            
            
        } else if Piece.isType(piece: piece, typeToCheck: .knight) {
            let knightsMoveset = [10, -10, 6, -6, 15, -15, 17, -17,]
            
            for move in knightsMoveset {
                let targetSquare = fromSquare + move
                if (0...63).contains(targetSquare) {
                    if board[targetSquare] == 0 {
                        moves.append(Move(fromSquare: fromSquare, targetSquare: targetSquare))
                    } else if Piece.areOppositeColors(piece1: piece, piece2: board[targetSquare]) {
                            moves.append(Move(fromSquare: fromSquare, targetSquare: targetSquare))
                        }
                }
            }
        } else {
            let kingsMoveset = [1, -1, 8, -8]
            
            if !Piece.checkIfCheck(board: board) {
                for move in kingsMoveset {
                    let targetSquare = fromSquare + move
                    if (0...63).contains(targetSquare) {
                        //todo sprawdzenie czy pole nie jest szachowane, czy pole nie jest bronione, roszada
                        
                        //zwykly ruch
                        if board[targetSquare] == 0 {
                            moves.append(Move(fromSquare: fromSquare, targetSquare: targetSquare))
                        }
                        
                        //roszada
                        
                    }
                }
            }
        }
        
    }
    
    func makeMove(move: Move) {
        
        guard let from = move.fromSquare else { return }
        guard let target = move.targetSquare else { return }
        
        print(from, target)
        board.swapAt(from, target)
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
    
    static let directionOffsets = [8, -8, -1, 1, 7, -7, 9, -9]
    
}

