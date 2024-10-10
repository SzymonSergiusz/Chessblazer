//
//  main.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation

let engine = Engine()

while !engine.quit {
    if let input = readLine() {
        engine.getInput(command: input)
    }
}
