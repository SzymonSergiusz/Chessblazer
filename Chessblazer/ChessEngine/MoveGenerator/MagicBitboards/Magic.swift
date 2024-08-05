//
//  Magic.swift
//  Chessblazer
//
//  Created by sergiusz on 30/07/2024.
//

import Foundation

class Magic {
    
    static var rookMasks: [Bitboard] = generateRookMasks()
    
    static func generateRookMask(square: Int) -> Bitboard {
        
        let rank = square / 8
        let file = square % 8
        
        var rankMask = Bitboard.Masks.rank1 << (Bitboard(rank * 8))
        var fileMask = Bitboard.Masks.fileA << Bitboard(file)
        
        //excluding A and H file
//        rankMask = (rankMask & ~Bitboard.Masks.fileA) & ~Bitboard.Masks.fileH
//        fileMask = fileMask & ~(Bitboard.Masks.rank1 | Bitboard.Masks.rank8)
        rankMask = rankMask & ~(Bitboard.Masks.fileA | Bitboard.Masks.fileH)
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
        var mask = movementMask
        
        while mask != 0 {
            indexesToCheck.append(Bitboard.popLSB(&mask))
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

    static func hashKeyRook(blockerBitboard: Bitboard, square: Int) -> UInt64 {
        let magic = rookMagics[square]
        let shift = rookShifts[square]
        let of = blockerBitboard.rawValue.multipliedReportingOverflow(by: magic)
        return (of.0) >> shift
    }

    
    static func createRookLegalMoves(square: Int, blocker: Bitboard) -> Bitboard {
        var legalMoves = Bitboard(0)
        
        // N, S, E, W
        let directions: [(Int, Int)] = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        
        for (deltaRow, deltaCol) in directions {
            var currentSquare = square
            
            while true {
                let newRow = currentSquare / 8 + deltaRow
                let newCol = currentSquare % 8 + deltaCol
                
                if newRow < 0 || newRow >= 8 || newCol < 0 || newCol >= 8 {
                    break
                }
                
                let newSquare = newRow * 8 + newCol
                
                legalMoves = legalMoves | Bitboard(1) << Bitboard(newSquare)

                if (blocker.rawValue & (1 << newSquare)) != 0 {
                            break
                }
                
//                if (blocker >> Bitboard(newSquare) & Bitboard(1)) != 0 {
//                    break
//                }
//                                legalMoves = legalMoves | Bitboard(1) << Bitboard(newSquare)

                currentSquare = newSquare
            }
        }
        return legalMoves
    }

//    static func createRookLookupTable() -> [Int: [UInt64: Bitboard]] {
//        var rookMovesLookup = [Int: [UInt64: Bitboard]]()
//        for square in 0...63 {
//            let movementMask = Magic.rookMasks[square]
//            let blockers = createAllBlockers(movementMask: movementMask)
//            rookMovesLookup[square] = [:]
//
//            for blocker in blockers {
//                let legalMoves: Bitboard = createRookLegalMoves(square: square, blocker: blocker)
//                rookMovesLookup[square]?[hashKeyRook(blockerBitboard: blocker, square: square)] = legalMoves
//            }
//        }
//        return rookMovesLookup
//    }
    
    struct KeyTuple: Hashable {
        init(_ first: Int, _ second: UInt64) {
            self.first = first
            self.second = second
        }
        var first: Int
        var second: UInt64
    }
    
    static func createRookLookupTable() -> [KeyTuple: Bitboard] {
        var rookMovesLookup = [KeyTuple: Bitboard]()
        for square in 0...63 {
            let movementMask = Magic.rookMasks[square]
            let blockers = createAllBlockers(movementMask: movementMask)

            for blocker in blockers {
                let legalMoves: Bitboard = createRookLegalMoves(square: square, blocker: blocker)
                rookMovesLookup[KeyTuple(square, blocker.rawValue)] = legalMoves
            }
        }
        return rookMovesLookup
    }
    

    static var bishopMasks: [Bitboard] = generateBishopMasks()
    
//    static let bishopLookupTable: [Int: [UInt64: Bitboard]] = createBishopLookupTable()
    static let bishopLookupTable: [KeyTuple : Bitboard] = createBishopLookupTable()

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
    
    static func hashKeyBishop(blockerBitboard: Bitboard, square: Int) -> UInt64 {
        let magic = bishopMagics[square]
        let shift = bishopShifts[square]
        let of = blockerBitboard.rawValue.multipliedReportingOverflow(by: magic)
        return (of.0) >> shift
    }
    
    
//    static func createBishopLookupTable() -> [Int: [UInt64: Bitboard]] {
//        var bishopMovesLookup: [Int: [UInt64: Bitboard]] = [:]
//        for square in 0...63 {
//            let movementMask = Magic.bishopMasks[square] //ok
//            let blockers = createAllBlockers(movementMask: movementMask) // raczej ok
//            bishopMovesLookup[square] = [:]
//            
//            for blocker in blockers {
//                let legalMoves: Bitboard = createBishopLegalMoves(square: square, blocker: blocker)
//                bishopMovesLookup[square]![hashKeyBishop(blockerBitboard: blocker, square: square)] = legalMoves
//            }
//        }
//        return bishopMovesLookup
//    }
    
    
    static func createBishopLookupTable() -> [KeyTuple: Bitboard] {
        var bishopMovesLookup: [KeyTuple: Bitboard] = [:]
        for square in 0...63 {
            let movementMask = Magic.bishopMasks[square] //ok
            let blockers = createAllBlockers(movementMask: movementMask) // raczej ok

            for blocker in blockers {
                let legalMoves: Bitboard = createBishopLegalMoves(square: square, blocker: blocker)
                bishopMovesLookup[KeyTuple(square, blocker.rawValue)] = legalMoves
            }
        }
        return bishopMovesLookup
    }
    
//    static func createBishopLegalMoves(square: Int, blocker: Bitboard) -> Bitboard {
//
//        
//    }


    static func createBishopLegalMoves(square: Int, blocker: Bitboard) -> Bitboard {
        var legalMoves = Bitboard(0)
        
        // NE, NW, SE, SW directions
        let directions: [(Int, Int)] = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
        
        for (deltaRow, deltaCol) in directions {
            var currentRow = square / 8
            var currentCol = square % 8
            
            while true {
                currentRow += deltaRow
                currentCol += deltaCol
                
                if currentRow < 0 || currentRow >= 8 || currentCol < 0 || currentCol >= 8 {
                    break
                }
                
                let newSquare = currentRow * 8 + currentCol
                legalMoves = Bitboard(legalMoves.rawValue | 1 << newSquare)
                
                // Stop if there's a blocker at this square
                if (blocker.rawValue & (1 << newSquare)) != 0 {
                    break
                }
            }
        }
        
        return legalMoves
    }

    
//    static func createBishopLegalMoves(square: Int, blocker: Bitboard) -> Bitboard {
//        var legalMoves = Bitboard(0)
//        
//        // NE, NW, SE, SW directions
//        let directions: [(Int, Int)] = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
//        
//        for (deltaRow, deltaCol) in directions {
//            var currentSquare = square
//            
//            while true {
//                let newRow = currentSquare / 8 + deltaRow
//                let newCol = currentSquare % 8 + deltaCol
//                
//                if newRow < 0 || newRow >= 8 || newCol < 0 || newCol >= 8 {
//                    break
//                }
//                
//                let newSquare = newRow * 8 + newCol
//                legalMoves = legalMoves | (Bitboard(1) << Bitboard(newSquare))
//                
//                // Stop if there's a blocker at this square
//                if (blocker >> Bitboard(newSquare) & Bitboard(1)) != 0 {
//                    break
//                }
//                
//                currentSquare = newSquare
//            }
//        }
//        
//        return legalMoves
//    }
}




