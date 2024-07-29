//
//  Engine.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation
class Engine {
    let engineName = "Chessblazer"
    let engineVersion = "very alpha 0.00001"
    var quit = false
    let engineAuthor = "sergiusz"
    var engineId: String {
        engineName+" "+engineAuthor
    }
    
    var game = Game()
    
    func start(white player1: Player, black player2: Player) -> Bool {
        
        return true
    }
    func getInput(command input: String) {
        let args = input.components(separatedBy: .whitespaces)
        guard let command = CommandsGUItoEngine(rawValue: args[0]) else { return }

        switch command {
        case .uci:
            sendOutput(output: engineId)
            sendOutput(output: "uciok")
        case .isready:
            sendOutput(output: "readyok")
        case .ucinewgame:
            game.startNewGame()
            
        case .position:
            
            if args[1] == "fen" {
                game.loadBoardFromFen(fen: args[2])
            } else if args[1] == "startpos" {
                if args[2] == "moves" {
                    let moves = args[3..<args.count]
                    for move in moves {
                        game.makeMove(board: &game.board, move: Move(notation: "move"))
                    }
                    
                }
            }
//           var argIndex = 1
//            if args[argIndex] == "startpos" {
//                game.startNewGame()
//                argIndex += 1
//            } else if args[argIndex] == "fen" {
//                let fenParts = args[argIndex + 1...(args.count - 1)].prefix(6)
//                let fen = fenParts.joined(separator: " ")
//                game.loadBoardFromFen(fen: fen)
//                argIndex += 7
//            }
//            
//            if argIndex < args.count && args[argIndex] == "moves" {
//                argIndex += 1
//                for i in argIndex..<args.count {
//                    game.makeMove(board: &game.board, move: Move(notation: args[i]))
//                }
//            }

        case .go:
//            let randomMove = game.generatePseudoLegalMoves(forColor: game.currentTurnColor).randomElement() ?? Move(notation: "e2e4")
//            let toNotation = randomMove.moveToNotation()
//            sendOutput(output: "bestmove \(toNotation)")
            sendOutput(output: "")
        case .stop:
            let randomMove = game.generatePseudoLegalMoves(forColor: game.currentTurnColor).randomElement() ?? Move(notation: "e2e4")
            let toNotation = randomMove.moveToNotation()
            sendOutput(output: "bestmove \(toNotation)")
        case .quit:
            quit = true
            
        case .printBoard:
            let printer = BoardPrinter()
            printer.printBoard(board: game.board, emojiMode: true, perspectiveColor: .white)
        default:
            return
        }
    }


    func sendOutput(output: String) {
        print(output)
    }
}

enum CommandsGUItoEngine: String {
    case uci
    case debug
    case isready
    case setoption
    case register
    case ucinewgame
    case position // position [fen <fenstring> | startpos ]  moves <move1> .... <movei>
    case go
    case stop
    case ponderhit
    case quit
    //custom
    case printBoard
}

enum CommandsEnginetoGUI {
    case id
    case uciok
    case readyok
    case bestmove
    case copyprotection
    case registration
    //...
}


/*
 The engine should boot and wait for input from the GUI,
   the engine should wait for the "isready" or "setoption" command to set up its internal parameters
   as the boot process should be as quick as possible
 
 
 
 
 
 */
