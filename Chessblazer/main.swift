//
//  main.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation

let engine = Engine()
#if swift(>=6)
    print("swift 6")
#endif

while !engine.quit {
    if let input = readLine() {
        engine.getInput(command: input)
    }
}
