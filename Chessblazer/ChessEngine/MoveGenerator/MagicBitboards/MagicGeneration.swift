//
//  MagicGeneration.swift
//  Chessblazer
//
//  Created by sergiusz on 06/09/2024.
//

import Foundation

func findMagic<S: Slider>(slider: S.Type, magics: inout [UInt64], shifts: inout [Int]) {
    for square in 0...63 {
        let mask = slider.masks[square]
        let blockers = Magic.createAllBlockers(movementMask: mask)
        let bits = mask.nonzeroBitCount
        let shift = 64 - bits
        
        while true {
            let magic = UInt64.random(in: UInt64.min...UInt64.max) &
                        UInt64.random(in: UInt64.min...UInt64.max) &
                        UInt64.random(in: UInt64.min...UInt64.max)
            if testMagic(slider: slider, square: square, shift: shift, magic: magic, blockers: blockers) {
                print("founded magic: \(magic) shift: \(shift) for square \(square)")
                magics[square] = magic
                shifts[square] = shift
                break
            }
        }
    }
}

func testMagic<S: Slider>(slider: S.Type, square: Int, shift: Int, magic: UInt64, blockers: [Bitboard]) -> Bool {
    var table = [UInt64: Bitboard]()
    for blocker in blockers {
        let mask = slider.masks[square]
        let moves = slider.createLegalMoves(square: square, blocker: blocker & mask)
        let index = magicIndex(magic: magic, shift: shift, blocker: blocker & mask)
        if let existingMoves = table[index] {
            if existingMoves != moves {
                return false
            }
        } else {
            table[index] = moves
        }
    }
    return true
}

func magicIndex(magic: UInt64, shift: Int, blocker: Bitboard) -> UInt64 {
    let hash = blocker.multipliedReportingOverflow(by: magic)
    return hash.0 >> shift
}

func generateMagics() {
    var rookShifts: [Int] = Array(repeating: 0, count: 64)
    var rookMagics: [UInt64] = Array(repeating: 0, count: 64)
    
    var bishopMagics: [UInt64] = Array(repeating: 0, count: 64)
    var bishopShifts: [Int] = Array(repeating: 0, count: 64)
    
    findMagic(slider: Rook.self, magics: &rookMagics, shifts: &rookShifts)
    findMagic(slider: Bishop.self, magics: &bishopMagics, shifts: &bishopShifts)
    
    outputMagic(name: "rookShifts", array: rookShifts)
    outputMagic(name: "rookMagics", array: rookMagics)

    outputMagic(name: "bishopShifts", array: bishopShifts)
    outputMagic(name: "bishopMagics", array: bishopMagics)
}

func outputMagic(name: String, array: [Int]) {
    let strArr = array.map { String($0) }
    let str = strArr.joined(separator: ", ")
    intoFile(filename: name, content: str)
}

func outputMagic(name: String, array: [UInt64]) {
    let strArr = array.map { String($0) }
    let str = strArr.joined(separator: ", ")
    intoFile(filename: name, content: str)
}

func intoFile(filename: String, content: String) {
    do {
        let currentFilePath = URL(fileURLWithPath: #file)
        let projectFolderURL = currentFilePath.deletingLastPathComponent().deletingLastPathComponent()
        
        let fileURL = projectFolderURL.appendingPathComponent(filename)
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        print("File saved at: \(fileURL.path)")
    } catch {
        print("Error saving file: \(error)")
    }
}
