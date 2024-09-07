//
//  BitboardPrinters.swift
//  Chessblazer
//
//  Created by sergiusz on 29/07/2024.
//

import Foundation

extension Bitboard {
    func toBoardString() -> String {
        var boardString = ""
        let binaryString = String(self, radix: 2)
        let paddedBinaryString = String(repeating: "0", count: 64 - binaryString.count) + binaryString
        
        for row in 0..<8 {
            let start = paddedBinaryString.index(paddedBinaryString.startIndex, offsetBy: row * 8)
            let end = paddedBinaryString.index(start, offsetBy: 8)
            let rowString = String(paddedBinaryString[start..<end])
            boardString = rowString + "\n" + boardString
        }
        
        return boardString
    }
    
    
    func printBoardFromWhitePov() {
        let letters = (65...72).map { String(UnicodeScalar($0)!) }
        var numbers = 8
        
        for row in (0..<8).reversed() {
            print("")
            print(numbers, terminator: "")
            numbers -= 1
            
            for col in 0..<8 {
                let bitIndex = row * 8 + col
                let bitMask: UInt64 = 1 << bitIndex
                let pieceValue = (self & bitMask) != 0 ? 1 : 0
                
                
                print(" \(pieceValue)", terminator: " ")
                
            }
        }
        
        print()
        for letter in letters {
            print("  \(letter)", terminator: "")
        }
        
        print("")
    }


}
