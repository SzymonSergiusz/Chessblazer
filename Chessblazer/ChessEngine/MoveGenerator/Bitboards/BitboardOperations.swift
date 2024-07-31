//
//  BitboardOperations.swift
//  Chessblazer
//
//  Created by sergiusz on 29/07/2024.
//

import Foundation

extension Bitboard {
    static func << (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        let leftShift = lhs.rawValue << rhs.rawValue
        return Bitboard(leftShift)
    }
    
    static func >> (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        let rightShift = lhs.rawValue >> rhs.rawValue
        return Bitboard(rightShift)
    }
    
    static func & (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        let and = lhs.rawValue & rhs.rawValue
        return Bitboard(and)
    }
    
    static func | (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        let or = lhs.rawValue | rhs.rawValue
        return Bitboard(or)
    }
    
    static func ^ (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        let xor = lhs.rawValue ^ rhs.rawValue
        return Bitboard(xor)
    }
    
    static func < (lhs: Bitboard, rhs: Bitboard) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func > (lhs: Bitboard, rhs: Bitboard) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    static prefix func ~ (lhs: Bitboard) -> Bitboard {
        return Bitboard(~lhs.rawValue)
    }
    
    
    func eastOne() -> Bitboard {
        return (self << 1) & ~Bitboard.Masks.fileA
    }
    
    func westOne() -> Bitboard {
        return (self >> 1) & ~Bitboard.Masks.fileH
    }
    
    func northOne() -> Bitboard {
        return self << 8
    }
    
    func southOne() -> Bitboard {
        return self >> 8
    }
}
