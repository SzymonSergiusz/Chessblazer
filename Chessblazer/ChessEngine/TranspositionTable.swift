//
//  TranspositionTable.swift
//  Chessblazer
//
//  Created by sergiusz on 16/10/2024.
//

import Foundation


class TranspositionTable {
    
    struct TranspositionEntry {
        var moves: [Move] = []
        var attackBitboard = Bitboard(0)
        
        func toString() -> String {
            return ""
        }
    }
    
    
    var table: [Int : TranspositionEntry] = [:]
    
    func add(key: Int, entry: TranspositionEntry) {
        table[key] = entry
    }
    
    func load() {
        // loading from txt file
    }
    
    func get(key: Int) -> TranspositionEntry {
        return TranspositionEntry()
    }
    
    func save() {
        
    }
}

func hashZobrist(board: [Int]) {
    
}



