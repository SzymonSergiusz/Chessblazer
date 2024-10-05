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
    
    func getInput(command input: String) {
        let args = input.components(separatedBy: .whitespaces)
        guard let command = CommandsGUItoEngine(rawValue: args[0]) else { return }

        switch command {
        case .uci:
            sendOutput(output: engineId)
            sendOutput(output: "uciok")
        case .isready:
            // loadEngine first 
            sendOutput(output: "readyok")
        case .ucinewgame:
            game.startNewGame()
            
        case .position:
            #warning("refactor with regex for: position fen ... | position startpos moves ...")
            
            if args[1] == "fen" {
                game.loadBoardFromFen(fen: args[2])
            } else if args[1] == "startpos" {
                if args[2] == "moves" {
                    let moves = args[3..<args.count]
//                    for move in moves {
//                        game.makeMove(board: &game.board, move: Move(notation: "move"))
//                    }
                    
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
            //            let command = "go searchmoves e2e4 d2d4 ponder wtime 300000 btime 300000 winc 5000 binc 5000 movestogo 30 depth 20 nodes 1000000 mate 2 movetime 60000 infinite"

            let parsedParams = UciGoInput.parse(from: input)
            print("Parsed UCI Go Input:", parsedParams)
            
            // so go for dsl regex to capture all possible params and then handle it
            // if no depth then lets say depth = 50 and make it async so you can send signal to stop with .stop
            
            
        case .stop:
            // here should be sent signal to stop searching for best move
            
            print("")
        case .quit:
            quit = true
        
            
            
            
        // custom commands
        case .printBoard:
            print("")
        
        case .main:
            print()

        case .perft:
            print(perftParallel(depth: 1), ", expected: 20")
            print(perftParallel(depth: 2), ", expected: 400")
            print(perftParallel(depth: 3), ", expected: 8902")
            print(perftParallel(depth: 4), ", expected: 197281")
            
        case .promotion:
            var game = Game()
            let bp = BoardPrinter()
            
            
            game.loadBoardFromFen(fen: "8/PPP5/n7/Q7/3K1k2/8/1p1p1p1p/8 w - - 0 1")
            bp.printBoard(board: game.toBoardArrayRepresentation(), emojiMode: true)

            game.makeMove(move: Move(notation: "a7a8Q"))
            game.makeMove(move: Move(notation: "b2b1n"))
            
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
    case pve
    case main
    case promotion
    case perft
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

