//
//  Magic.swift
//  Chessblazer
//
//  Created by sergiusz on 30/07/2024.
//

import Foundation

class Magic {
    
    static var rookMasks: [Bitboard] = generateRookMasks()
    static var bishopMasks: [Bitboard] = generateBishopMasks()
    
    static func generateRookMask(square: Int) -> Bitboard {
        
        let rank = square / 8
        let file = square % 8
        
        var rankMask = Bitboard.Masks.rank1 << (Bitboard(rank * 8))
        var fileMask = Bitboard.Masks.fileA << Bitboard(file)
        
        //excluding A and H file
        rankMask = (rankMask & ~Bitboard.Masks.fileA) & ~Bitboard.Masks.fileH
        fileMask = fileMask & ~(Bitboard.Masks.rank1 | Bitboard.Masks.rank8)
        return rankMask | fileMask
    }
    
    static func generateRookMasks() -> [Bitboard] {
        var rookMasks: [Bitboard] = Array(repeating: Bitboard(0), count: 64)
        for squareIndex in 0...63 {
            rookMasks[squareIndex] = generateRookMask(square: squareIndex)
        }
        return rookMasks
    }
    
    static func generateBishopMask(square: Int) -> Bitboard {
        let rank = square / 8
        let file = square % 8
        var mask = Bitboard(0)
        for offset in 1..<8 {
            // NE
            if rank + offset < 8 && file + offset < 8 {
                mask = mask | Bitboard(1) << Bitboard(((rank + offset) * 8 + (file + offset)))
            }
            // NW
            if rank + offset < 8 && file - offset >= 0 {
                mask = mask | Bitboard(1) << Bitboard((rank + offset) * 8 + (file - offset))
            }
            // SE
            if rank - offset >= 0 && file + offset < 8 {
                mask = mask | Bitboard(1) << Bitboard((rank - offset) * 8 + (file + offset))
            }
            // SW
            if rank - offset >= 0 && file - offset >= 0 {
                mask = mask | Bitboard(1) << Bitboard((rank - offset) * 8 + (file - offset))
            }
        }
        
        return mask
    }
    
    static func generateBishopMasks() -> [Bitboard] {
        var bishopMasks: [Bitboard] = Array(repeating: Bitboard(0), count: 64)
        for squareIndex in 0...63 {
            bishopMasks[squareIndex] = generateBishopMask(square: squareIndex)
        }
        return bishopMasks
    }
    
    static func whitePiecesBitboards(bitboards: [Int: Bitboard]) -> Bitboard {
        var bitboard = Bitboard(0)
        
        for board in bitboards {
            if Piece.checkColor(piece: board.key) == .white {
                bitboard = bitboard | board.value
            }
        }
        return bitboard
    }
    
    static func blackPiecesBitboards(bitboards: [Int: Bitboard]) -> Bitboard {
        var bitboard = Bitboard(0)
        
        for board in bitboards {
            if Piece.checkColor(piece: board.key) == .black {
                bitboard = bitboard | board.value
            }
        }
        return bitboard
    }
    
    static func allPieces(bitboards: [Int: Bitboard]) -> Bitboard {
        return whitePiecesBitboards(bitboards: bitboards) | blackPiecesBitboards(bitboards: bitboards)
    }
    
    
    static func createAllBlockers(movementMask: Bitboard) -> [Bitboard] {
        
        var indexesToCheck = [Int]()
        
        for i in 0...63 {
            if ((movementMask >> Bitboard(i)) & Bitboard(1) == 1) {
                indexesToCheck.append(i)
            }
        }
        
        let numberOfDiffBitboards = 1 << indexesToCheck.count // 2^n
        var blockers = Array(repeating: Bitboard(0), count: numberOfDiffBitboards)
        
        for patternIndex in 0..<numberOfDiffBitboards {
            for bitIndex in 0..<indexesToCheck.count {
                let bit = (patternIndex >> bitIndex) & 1
                blockers[patternIndex] = blockers[patternIndex] | (Bitboard(bit) << Bitboard(indexesToCheck[bitIndex]))
            }
        }
        return blockers
    }
    
    static let rookLookupTable = createRookLookupTable()

    static func hashKey(blockerBitboard: Bitboard, square: Int) -> UInt64 {
        let magic = rookMagics[square]
        let shift = rookShifts[square]
        return (blockerBitboard.rawValue &* magic) >> shift
    }
    
    
    static func generateRookMoves(game: Game, square: Int, moves: inout [Move]) {
        let whitePieces = whitePiecesBitboards(bitboards: game.bitboards)
        let blackPieces = blackPiecesBitboards(bitboards: game.bitboards)
        let allPieces = whitePieces | blackPieces
        #warning("no check xray mask")
        let blockerBitboard = allPieces & rookMasks[square] // & checkRayMask
        let key: UInt64 = hashKey(blockerBitboard: blockerBitboard, square: square)

        var movesBitboard = rookLookupTable[square]![key]!
        if game.currentTurnColor == .white {
            movesBitboard = movesBitboard & ~whitePieces
        } else {
            movesBitboard = movesBitboard & ~blackPieces
        }
        
        #warning("no pin mask check yet")
        //movesBitboard = movesBitboard & getPinMask()
        
        #warning("it prints correct moves")
        movesBitboard.printBoardFromWhitePov()
        
        while movesBitboard != 0 {
            let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
            moves.append(Move(fromSquare: square, targetSquare: targetSquare))
        }
    }
    
    #warning("both function are ok")
    static func createRookLegalMoves(square: Int, blocker: Bitboard) -> Bitboard {
        var legalMoves = Bitboard(0)
        let movementMask = Magic.rookMasks[square]
        
        // Iterate through each direction: N, S, E, W
        let directions: [(Int, Int)] = [(0, 1), (0, -1), (1, 0), (-1, 0)] // (deltaRow, deltaCol)
        
        for (deltaRow, deltaCol) in directions {
            var currentSquare = square
            
            while true {
                let newRow = currentSquare / 8 + deltaRow
                let newCol = currentSquare % 8 + deltaCol
                
                // Check if new position is valid
                if newRow < 0 || newRow >= 8 || newCol < 0 || newCol >= 8 {
                    break // Out of bounds
                }
                
                let newSquare = newRow * 8 + newCol
                
                // Check if there is a blocker in the way
                if (blocker >> Bitboard(newSquare) & Bitboard(1)) != 0 {
                    break // Blocked by a piece
                }
                
                // Add the new square to legal moves
                legalMoves = legalMoves | Bitboard(1) << Bitboard(newSquare)
                
                // Continue in the same direction
                currentSquare = newSquare
            }
        }
        
        return legalMoves
    }
    
//    static func createRookLegalMoves(square: Int, blocker: Bitboard) -> Bitboard {
//        var legalMoves = Bitboard(0)
//        let rank = square / 8
//        let file = square % 8
//
//        for delta in stride(from: file - 1, through: 0, by: -1) {
//            let targetSquare = rank * 8 + delta
//            legalMoves = legalMoves | (Bitboard(1) << Bitboard(targetSquare))
//            if (blocker >> Bitboard(targetSquare) & Bitboard(1)) != 0 {
//                break
//            }
//        }
//
//        for delta in file + 1..<8 {
//            let targetSquare = rank * 8 + delta
//            legalMoves = legalMoves | (Bitboard(1) << Bitboard(targetSquare))
//            if (blocker >> Bitboard(targetSquare) & Bitboard(1)) != 0 {
//                break
//            }
//        }
//
//        for delta in stride(from: rank - 1, through: 0, by: -1) {
//            let targetSquare = delta * 8 + file
//            legalMoves = legalMoves | (Bitboard(1) << Bitboard(targetSquare))
//            if (blocker >> Bitboard(targetSquare) & Bitboard(1)) != 0 {
//                break
//            }
//        }
//
//        for delta in rank + 1..<8 {
//            let targetSquare = delta * 8 + file
//            legalMoves = legalMoves | (Bitboard(1) << Bitboard(targetSquare))
//            if (blocker >> Bitboard(targetSquare) & Bitboard(1)) != 0 {
//                break
//            }
//        }
//
//        return legalMoves
//    }

    
    static func createRookLookupTable() -> [Int: [UInt64: Bitboard]] {
        var rookMovesLookup = [Int: [UInt64: Bitboard]]()

        for square in 0...63 {
            let movementMask = Magic.rookMasks[square]
            let blockers = createAllBlockers(movementMask: movementMask)
            rookMovesLookup[square] = [:] // Initialize the dictionary for each square

            for blocker in blockers {
                let legalMoves: Bitboard = createRookLegalMoves(square: square, blocker: blocker)
                rookMovesLookup[square]?[hashKey(blockerBitboard: blocker, square: square)] = legalMoves
            }
        }
        return rookMovesLookup
    }
}




