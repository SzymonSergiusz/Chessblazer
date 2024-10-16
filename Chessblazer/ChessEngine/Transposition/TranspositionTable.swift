//
//  TranspositionTable.swift
//  Chessblazer
//
//  Created by sergiusz on 16/10/2024.
//

import Foundation


// ######### WORK IN PROGRESS

let DB_NAME = "transposition_db.txt"
let ZB_KEYS = "zb_keys.txt"
class TranspositionTable {
    
    struct TranspositionEntry {
        var moves: [Move] = []
        var attackBitboard = Bitboard(0)
        
        func toString() -> String {
            return ""
        }
    }
    
    
    
    var zobristKeys: ZobristKeys
    
    var table: [Int : TranspositionEntry] = [:]
    
    init(zobristKeys: ZobristKeys, table: [Int : TranspositionEntry]) {
        self.zobristKeys = zobristKeys
        self.table = table
    }
    // explanation: no point to generate it now, better make it consts
    //    func loadZobristKeys() -> ZobristKeys {
    //        // ColoredPiece.rawValue : randomKey, ColoredPiece.rawValue : randomKey, ...,
    //
    //        let currentDir = URL(fileURLWithPath: #file).deletingLastPathComponent()
    //        let zbKey = ZobristKeys(pieceKeys: [:], enPassantKeys: [], castleKeys: [], sideKey: 0)
    //        let keysFile = currentDir.appendingPathComponent(ZB_KEYS).path()
    //        if FileManager.default.fileExists(atPath: keysFile) {
    //            let data = keysFile.data(using: .utf8)!
    //            let split = String(data: data, encoding: .utf8)!.components(separatedBy: ",")
    //
    //            for i in 0...11 {
    //                let pieceKey = split[i].components(separatedBy: ":")
    //                let piece = Int(pieceKey[0])
    //                let key = Int(pieceKey[1])
    //
    //            }
    //
    //        } else {
    //
    //        }
    //
    //
    //
    //        let keys = ZobristKeys()
    //
    //
    //
    //        return keys
    //    }
    //
    func loadTranspositionTable() {
        // loading from txt file
        /*
         {
         
         
         }
         
         
         */
    }
    
    func add(key: Int, entry: TranspositionEntry) {
        table[key] = entry
    }
    
    
    
    func get(key: Int) -> TranspositionEntry {
        return TranspositionEntry()
    }
    
    //    func save(entry: TranspositionEntry) {
    //        do {
    //            let currentFolder = URL(fileURLWithPath: #file).deletingLastPathComponent()
    //            let file = currentFolder.appendingPathComponent(DB_NAME)
    //            FileManager.default.currentDirectoryPath.
    //            if FileManager.default.fileExists(atPath: file.path()) {
    //
    //            }
    //
    //
    //            try entry.toString().write(to: file, atomically: true, encoding: .utf8)
    //        } catch {
    //        }
    //    }
}

func hashZobrist(board: [Int]) {
    
}

struct ZobristKeys: Codable {
    var pieceKeys: [Int: [Int]]
    var enPassantKeys: [Int]
    var castleKeys: [Int]
    var sideKey: Int
    
    
    func string() -> String {
        var str = ""
        for (piece, squares) in pieceKeys {
            str += String(piece)+":"
            for square in squares {
                str += String(square)+","
            }
            str+="\n"
        }
        
        return str
    }
}

func generateKeys() -> ZobristKeys {
    func random() -> Int {
        return Int.random(in: Int.min...Int.max)
    }
    
    var pieceKeys: [Int: [Int]] = [:]
    var enPassantKeys: [Int] = Array(repeating: 0, count: 8)
    var castleKeys: [Int] = Array(repeating: 0, count: 4)
    
    for file in 0...7 {
        enPassantKeys[file] = random()
    }
    for piece in Piece.ColoredPieces.allCases {
        if piece.rawValue != 0 {
            pieceKeys.updateValue([], forKey: piece.rawValue)
        }
    }
    
    for piece in Piece.ColoredPieces.allCases {
        
        
        
        
        if piece.rawValue != 0 {
            for _ in 0...63 {
                pieceKeys[piece.rawValue]!.append(random())
            }
        }
    }
    
    let sideKey = random()
    
    // 0 1 2 3
    // k q K Q
    for i in 0...3 {
        castleKeys[i] = random()
    }
    return ZobristKeys(pieceKeys: pieceKeys, enPassantKeys: enPassantKeys, castleKeys: castleKeys, sideKey: sideKey)
}

func saveKeys() {
    let dir = URL(filePath: #file).deletingLastPathComponent().appendingPathComponent(ZB_KEYS)
    let keys = generateKeys()
    print(keys.string())
    FileManager.default.createFile(atPath: dir.path(), contents: keys.string().data(using: .utf8))
}

func loadKeys() {
    
}
