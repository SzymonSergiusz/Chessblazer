//
//  main.swift
//  Chessblazer
//
//  Created by Szymon Kluska on 25/07/2024.
//

import Foundation


//let engine = Engine()
//
//let game = Game()
//game.loadBoardFromFen(fen: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1")
//let boardPrinter = BoardPrinter()
//
//boardPrinter.printBoard(board: game.board, emojiMode: true, perspectiveColor: .white)
//game.makeMove(move: Move(notation: "e7e5"))
//game.makeMove(move: Move(notation: "d2d4"))
//game.makeMove(move: Move(notation: "d7d5"))
//
//boardPrinter.printBoard(board: game.board, emojiMode: true, perspectiveColor: .white)
//
//boardPrinter.printPossibleMoves(game: game)
//
//
//
//
//var isGameOn = engine.start(white: Human(), black: AIPlayer())

let engine = Engine()
while !engine.quit {
    if let input = readLine() {
        engine.getInput(command: input)
    }
}
