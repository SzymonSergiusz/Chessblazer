//
//  Bitboard.swift
//  Chessblazer
//
//  Created by sergiusz on 29/07/2024.
//
// special thanks to https://www.magnuskahr.dk/posts/2019/10/bitboards-in-swift/
import Foundation
struct Bitboard: Equatable {
    private(set) var rawValue: UInt64
    init(_ rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    init(_ rawValue: Int) {
        self.rawValue = UInt64(rawValue)
    }
    
    func toString() -> String {
        String(rawValue)
    }
    
    //      # Little-Endian Rank-File Mapping #
    //    a-file             0x0101010101010101
    //    h-file             0x8080808080808080
    //    1st rank           0x00000000000000FF
    //    8th rank           0xFF00000000000000
    //    a1-h8 diagonal     0x8040201008040201
    //    h1-a8 antidiagonal 0x0102040810204080
    //    light squares      0x55AA55AA55AA55AA
    //    dark squares       0xAA55AA55AA55AA55
    
    struct Masks {
        static let fileA: Bitboard = 0x0101010101010101
        static let fileH: Bitboard = 0x8080808080808080
        static let fileAB: Bitboard = 0x0303030303030303
        static let fileGH: Bitboard = 0xC0C0C0C0C0C0C0C0
        static let rank1: Bitboard = 0x00000000000000FF
        static let rank8: Bitboard = 0xFF00000000000000
        static let diagonalA1H8: Bitboard = 0x8040201008040201
        static let diagonalH1A8: Bitboard = 0x0102040810204080
        static let whiteSquares: Bitboard = 0x55AA55AA55AA55AA
        static let blackSquares: Bitboard = 0xAA55AA55AA55AA55
        static let rank4: Bitboard = 0x00000000FF000000
        static let rank5: Bitboard = 0x000000FF00000000
    }
}

extension Bitboard: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt64) {
        self.init(value)
    }
}


