//
//  Engine.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation

class Engine {
    let engineName = "Chessblazer"
    let engineVersion = "alpha 0.001"
    var quit = false
    let engineAuthor = "sergiusz"
    
    var game = Game()
    
    func getInput(command input: String) {
        let args = input.components(separatedBy: .whitespaces)
        guard let command = CommandsGUItoEngine(rawValue: args[0]) else { return }

        switch command {
        case .uci:
            sendOutput(output: "id name \(engineName)")
            sendOutput(output: "id author \(engineAuthor)")
            sendOutput(output: "uciok")
        case .isready:
            // loadEngine first 
            sendOutput(output: "readyok")
        case .ucinewgame:
            game.startNewGame()
            
        case .position:
            if args[1] == "fen" {
                game.loadFromFen(fen: args[2])
            } else if args[1] == "startpos" {
                game.startNewGame()
                if args.indices.contains(2), args[2] == "moves" {
                    let moves = args[3..<args.count]
                    for move in moves {
                        game.makeMove(move: game.findMove(notation: move))
                        
                    }
                }
            }

        case .go:
            //            let command = "go searchmoves e2e4 d2d4 ponder wtime 300000 btime 300000 winc 5000 binc 5000 movestogo 30 depth 20 nodes 1000000 mate 2 movetime 60000 infinite"

            let parsedParams = UciGoInput.parse(from: input)
//            print("Parsed UCI Go Input:", parsedParams)
            let bestMove = game.boardState.currentTurnColor == .white ? findBestMove(game: game, depth: 3, maximizingPlayer: true) : findBestMove(game: game, depth: 3, maximizingPlayer: false)
            if let move = bestMove {
                print("bestmove \(moveToNotation(move: move))")
            }
            // so go for dsl regex to capture all possible params and then handle it
            // if no depth then lets say depth = 50 and make it async so you can send signal to stop with .stop
            
            
        case .stop:
            // here should be sent signal to stop searching for best move
            
            print("")
        case .quit:
            quit = true
        
            
            
            
        // custom commands
            
        case .eve:
            let game = Game()
            game.startNewGame()
            let bp = BoardPrinter()
            bp.printBoard(board: game.toBoardArrayRepresentation())

            while !game.boardData.hasGameEnded {
                let bestMove = game.boardState.currentTurnColor == .white ? findBestMove(game: game, depth: 3, maximizingPlayer: true) : findBestMove(game: game, depth: 3, maximizingPlayer: false)
                
                game.makeMove(move: bestMove!)
                bp.printBoard(board: game.toBoardArrayRepresentation())
                
            }
            
        case .printBoard:
            print("")
        
        case .main:
            saveKeys()
            
        case .mateInOne:
            let bp = BoardPrinter()
            let game = Game()
            //rnb1k1nr/pppp1ppp/5q2/2b1p3/2B1P2P/N7/PPPP1PP1/R1BQK1NR b KQkq - 0 4
            game.loadFromFen(fen: "rnbqkbnr/1ppp1pp1/7p/p3p3/2B1P3/5Q2/PPPP1PPP/RNB1K1NR w KQkq - 0 4")
            let bestMove = game.boardState.currentTurnColor == .white ? findBestMove(game: game, depth: 3, maximizingPlayer: true) : findBestMove(game: game, depth: 3, maximizingPlayer: false)
            
            game.makeMove(move: bestMove!)
            bp.printBoard(board: game.toBoardArrayRepresentation())
            
            
        case .promotion:
            let bp = BoardPrinter()
            game.loadFromFen(fen: "6br/5Ppk/7p/5K2/8/8/8/8 w - - 0 1")
            
            bp.printBoard(board: game.toBoardArrayRepresentation(), emojiMode: true)
            let bestMove = game.boardState.currentTurnColor == .white ? findBestMove(game: game, depth: 3, maximizingPlayer: true) : findBestMove(game: game, depth: 3, maximizingPlayer: false)
            game.makeMove(move: bestMove!)
            bp.printBoard(board: game.toBoardArrayRepresentation(), emojiMode: true)
            
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
    case eve // Engine vs Engine
    case mateInOne
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

