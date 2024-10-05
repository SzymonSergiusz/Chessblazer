//
//  UciUtils.swift
//  Chessblazer
//
//  Created by sergiusz on 05/10/2024.
//

import Foundation
import RegexBuilder
struct UciGoInput {
    var searchMoves = [Move]()
    var ponder: Bool = false
    var whiteTime: Int = 0 // x ms
    var blackTime: Int = 0
    var whiteIncrementTime: Int = 0
    var blackIncrementTime: Int = 0
    var movesToGo: Int = 0
    var depth: Int = 3
    var nodes: Int = 3
    var searchMateIn: Int = 1
    var searchMoveTime: Int = 5 //ms
    var infinite: Bool = false
    
    static func parse(from: String) -> UciGoInput {
        var result = UciGoInput()
        
        let searchMovesRegex = Regex {
            "searchmoves"
            OneOrMore(.whitespace)
            Capture {
                OneOrMore(.word)
                ZeroOrMore {
                    OneOrMore(.whitespace)
                    OneOrMore(.word)
                }
            }
            OneOrMore(.whitespace)
            "ponder"
        }
        
        let ponderRegex = Regex {
            "ponder"
        }
        
        let wtimeRegex = Regex {
            "wtime"
            OneOrMore(.whitespace)
            Capture {
                OneOrMore(.digit)
            }
        }
        
        let btimeRegex = Regex {
            "btime"
            OneOrMore(.whitespace)
            Capture {
                OneOrMore(.digit)
            }
        }
        
        let wincRegex = Regex {
            "winc"
            OneOrMore(.whitespace)
            Capture {
                OneOrMore(.digit)
            }
        }
        
        let bincRegex = Regex {
            "binc"
            OneOrMore(.whitespace)
            Capture {
                OneOrMore(.digit)
            }
        }
        
        let movesToGoRegex = Regex {
            "movestogo"
            OneOrMore(.whitespace)
            Capture {
                OneOrMore(.digit)
            }
        }
        
        let depthRegex = Regex {
            "depth"
            OneOrMore(.whitespace)
            Capture {
                OneOrMore(.digit)
            }
        }
        
        let nodesRegex = Regex {
            "nodes"
            OneOrMore(.whitespace)
            Capture {
                OneOrMore(.digit)
            }
        }
        
        let mateRegex = Regex {
            "mate"
            OneOrMore(.whitespace)
            Capture {
                OneOrMore(.digit)
            }
        }
        
        let movetimeRegex = Regex {
            "movetime"
            OneOrMore(.whitespace)
            Capture {
                OneOrMore(.digit)
            }
        }
        
        let infiniteRegex = Regex {
            "infinite"
        }
        
        if let match = from.firstMatch(of: searchMovesRegex) {
  
            result.searchMoves = match.1.split(separator: " ").map {
                Move(notation: String($0))
            }
        }
        
        if from.contains(ponderRegex) {
            result.ponder = true
        }
        
        if let match = from.firstMatch(of: wtimeRegex) {
            result.whiteTime = Int(match.1) ?? 0
        }
        
        if let match = from.firstMatch(of: btimeRegex) {
            result.blackTime = Int(match.1) ?? 0
        }
        
        if let match = from.firstMatch(of: wincRegex) {
            result.whiteIncrementTime = Int(match.1) ?? 0
        }
        
        if let match = from.firstMatch(of: bincRegex) {
            result.blackIncrementTime = Int(match.1) ?? 0
        }
        
        if let match = from.firstMatch(of: movesToGoRegex) {
            result.movesToGo = Int(match.1) ?? 0
        }
        
        if let match = from.firstMatch(of: depthRegex) {
            result.depth = Int(match.1) ?? 3
        }
        
        if let match = from.firstMatch(of: nodesRegex) {
            result.nodes = Int(match.1) ?? 3
        }
        
        if let match = from.firstMatch(of: mateRegex) {
            result.searchMateIn = Int(match.1) ?? 1
        }
        
        if let match = from.firstMatch(of: movetimeRegex) {
            result.searchMoveTime = Int(match.1) ?? 5
        }
        
        if from.contains(infiniteRegex) {
            result.infinite = true
        }
        
        return result
    }
}
