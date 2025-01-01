//
//  Bitboard.swift
//  Chessblazer
//
//  Created by sergiusz on 29/07/2024.
//
// special thanks to https://www.magnuskahr.dk/posts/2019/10/bitboards-in-swift/
import Foundation
typealias Bitboard = UInt64

extension UInt64 {
    struct Masks {
        static let fileA: Bitboard = 0x0101010101010101
        static let fileH: Bitboard = 0x8080808080808080
        static let fileAB: Bitboard = 0x0303030303030303
        static let fileGH: Bitboard = 0xC0C0C0C0C0C0C0C0
        static let rank1: Bitboard = 0x00000000000000FF
        static let rank2: Bitboard = 0x000000000000FF00
        static let rank7: Bitboard = 0x00FF000000000000
        static let rank8: Bitboard = 0xFF00000000000000
        static let diagonalA1H8: Bitboard = 0x8040201008040201
        static let diagonalH1A8: Bitboard = 0x0102040810204080
        static let whiteSquares: Bitboard = 0x55AA55AA55AA55AA
        static let blackSquares: Bitboard = 0xAA55AA55AA55AA55
        static let rank4: Bitboard = 0x00000000FF000000
        static let rank5: Bitboard = 0x000000FF00000000
    }
}

//extension Bitboard: ExpressibleByIntegerLiteral {
//    public init(integerLiteral value: UInt64) {
//        self.init(value)
//    }
//    
//    
//}


//
//  BitboardOperations.swift
//  Chessblazer
//
//  Created by sergiusz on 29/07/2024.
//

import Foundation

extension Bitboard {
//    static func << (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
//        let leftShift = lhs.rawValue << rhs.rawValue
//        return Bitboard(leftShift)
//    }
//    
//    static func >> (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
//        let rightShift = lhs.rawValue >> rhs.rawValue
//        return Bitboard(rightShift)
//    }
//    
//    static func & (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
//        let and = lhs.rawValue & rhs.rawValue
//        return Bitboard(and)
//    }
//    
//    static func | (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
//        let or = lhs.rawValue | rhs.rawValue
//        return Bitboard(or)
//    }
//    
//    static func ^ (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
//        let xor = lhs.rawValue ^ rhs.rawValue
//        return Bitboard(xor)
//    }
//    
//    static func < (lhs: Bitboard, rhs: Bitboard) -> Bool {
//        return lhs.rawValue < rhs.rawValue
//    }
//    
//    static func > (lhs: Bitboard, rhs: Bitboard) -> Bool {
//        return lhs.rawValue > rhs.rawValue
//    }
//    static prefix func ~ (lhs: Bitboard) -> Bitboard {
//        return Bitboard(~lhs.rawValue)
//    }
    
    
    func eastOne() -> Bitboard {
        return (self << 1) & ~Bitboard.Masks.fileA
    }
    
    func westOne() -> Bitboard {
        return (self >> 1) & ~Bitboard.Masks.fileH
    }
    
    func northOne() -> Bitboard {
        return self << 8
    }
    
    func southOne() -> Bitboard {
        return self >> 8
    }
    
    func northEastOne() -> Bitboard {
        return Bitboard((self << 9) & ~Bitboard.Masks.fileA)
    }

    func northWestOne() -> Bitboard {
        return Bitboard((self << 7) & ~Bitboard.Masks.fileH)
    }

    func southEastOne() -> Bitboard {
        return Bitboard((self >> 7) & ~Bitboard.Masks.fileA)
    }

    func southWestOne() -> Bitboard {
        return Bitboard((self >> 9) & ~Bitboard.Masks.fileH)
    }
    
    
    static func popLSB(_ bitboard: inout Bitboard) -> Int {
        let lsb = bitboard & (~bitboard + 1)
        bitboard = bitboard & ~Bitboard(lsb)
        return lsb.trailingZeroBitCount
    }

    func countBits(_ bitboard: Bitboard) -> Int {
        return bitboard.nonzeroBitCount
    }
    
    func swapBits(bitboard: inout Bitboard, firstPosition: Int, secondPosition: Int) {
        let firstBit = (bitboard >> firstPosition) & 1
        let secondBit = (bitboard >> secondPosition) & 1
        
        if firstBit != secondBit {
            bitboard = bitboard ^ Bitboard((1 << firstPosition) | (1 << secondPosition))
        }
    }
}
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
//
//  BoardTerminalGUI.swift
//  Chessblazer
//
//  Created by sergiusz on 26/07/2024.
//

import Foundation
class BoardPrinter {
    
    func printBoard(board: [Int], emojiMode: Bool = true, perspectiveColor: Piece.Color = .white) {
        perspectiveColor == .white ? printBoardFromWhitePerspective(board: board, emojiMode: emojiMode) : printBoardBlackPerspective(board: board, emojiMode: emojiMode)
        
    }
    
    private func printBoardBlackPerspective(board: [Int], emojiMode: Bool = false) {
        let letters = (65...72).map { String(UnicodeScalar($0)!) }
        var numbers = 1
        
        for (index, value) in board.enumerated() {
            if index % 8 == 0 {
                print("")
                print(numbers, terminator: "")
                numbers += 1
            }
            if let pieceChar = emojiMode ? Piece.ValueToPieceEmojiDict[value] : Piece.ValueToPieceDict[value] {
                print(" \(pieceChar)", terminator: " ")
            } else {
                print(" ?", terminator: " ")
            }
            
            
        }
        print()
        for letter in letters {
            print("  \(letter)", terminator: "")
        }
        
        print("")
    }
    

    
    private func printBoardFromWhitePerspective(board: [Int], emojiMode: Bool = false) {
        let letters = (65...72).map { String(UnicodeScalar($0)!) }
        var numbers = 8
        
        for row in 0..<8 {
            let startIndex = (7 - row) * 8
            let endIndex = startIndex + 8
            let rowValues = board[startIndex..<endIndex]
            
            print("")
            print(numbers, terminator: "")
            numbers -= 1
            
            for value in rowValues {
                if let pieceChar = emojiMode ? Piece.ValueToPieceEmojiDict[value] : Piece.ValueToPieceDict[value] {
                    print(" \(pieceChar)", terminator: " ")
                } else {
                    print(" ?", terminator: " ")
                }
            }
        }
        
        print()
        for letter in letters {
            print("  \(letter)", terminator: "")
        }
        
        print("")
    }
    func debugPrint(board: [Int]) {
        print()
        for (index, value) in board.enumerated() {
            if index % 8 == 0 && index != 0 {
                print()
            }
            print("\(index):\(value)", terminator: " ")
        }
        print()
    }
}
//
//  BoardState.swift
//  Chessblazer
//
//  Created by sergiusz on 10/10/2024.
//

import Foundation

struct BoardState {
    var attackBitboard = Bitboard(0)
    var pawnAttackBitboard = Bitboard(0)
    var performedMovesList = [MoveData]()
    var castlesAvailable: Set<Character> = []
    var currentTurnColor: Piece.Color // = .white
    var bitboards: [Int: Bitboard] = initBitboards()
    var enPassant = "-"
    var currentValidMoves: [Move] = [Move]()
    
}

func initBitboards() -> [Int: Bitboard] {
    var bitboards = [Piece.ColoredPieces.RawValue : Bitboard]()
    for piece in Piece.ColoredPieces.allCases {
        if piece.rawValue != 0 {
            bitboards[piece.rawValue] = Bitboard(0)
        }
    }
    return bitboards
}

enum GameResult {
    case white, black, draw, none
}

struct BoardData {
    var halfMoves = 0
    var hasGameEnded = false
    var gameResult: GameResult = .none
}

struct PerftData {
    var captures: Int = 0
    var enPassants: Int = 0
    var castles: Int = 0
    var checks: Int = 0
    var checkmates: Int = 0
    var promotions: Int = 0
}

struct MoveData {
    var piece: Int
    var turn: Int
    var color: Piece.Color
    var move: Move
    var capturedPiece: Int?
    var bitboards: [Piece.ColoredPieces.RawValue : Bitboard]
    var castles: Set<Character>
    var currentValidMoves: [Move]
    var attackBitboard = Bitboard(0)
}


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
                print("bestmove \(move.moveToNotation())")
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

        case .perftX:
            let depth = Int(args[1]) ?? 0
            print(bulkPerftTest(depth: depth))
        case .perft:
            var position = ""
            if args.count > 1 {
                position = args[1]
            }
            switch position {
            
            case "2":
                print(perftTest(depth: 2, fen: "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -"))
                print(perftTest(depth: 3, fen: "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -"))
                print(perftTest(depth: 4, fen: "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -"))

            case "2b":
                print(bulkPerftTest(depth: 2, fen: "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -"))
                print(bulkPerftTest(depth: 3, fen: "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -"))
                print(bulkPerftTest(depth: 4, fen: "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -"))

            case "4":
                // 4    422333    131393    0    7795    60032    15492    5
                print(perftTest(depth: 1, fen: "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"))
                print(perftTest(depth: 2, fen: "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"))
                print(perftTest(depth: 3, fen: "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"))
                print(perftTest(depth: 4, fen: "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"))
                print(perftTest(depth: 5, fen: "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"))
                
            case "4b":
                // 4    422333    131393    0    7795    60032    15492    5
                print(bulkPerftTest(depth: 1, fen: "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"))
                print(bulkPerftTest(depth: 2, fen: "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"))
                print(bulkPerftTest(depth: 3, fen: "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"))
                print(bulkPerftTest(depth: 4, fen: "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"))
                print(bulkPerftTest(depth: 5, fen: "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"))

            default:
//                print(bulkPerftTest(depth: 1), ", expected: 20")
//                print(bulkPerftTest(depth: 2), ", expected: 400")
//                print(bulkPerftTest(depth: 3), ", expected: 8902")
//                print(bulkPerftTest(depth: 4), ", expected: 197281")
//                print(bulkPerftTest(depth: 5), ", expected: 4,865,609")
                
//                print(bulkPerftTest(depth: 6), ", expected: 119 060 324")
                print(bulkPerftTest(depth: 7), ", expected: 3 195 901 860")
                print(bulkPerftTest(depth: 8), ", expected: 84 998 978 956")
                print(bulkPerftTest(depth: 9), ", expected: 2 439 530 234 167")
            }

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
    case perft
    case perftX
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

//
//  Evaluation.swift
//  Chessblazer
//
//  Created by sergiusz on 06/08/2024.
//

import Foundation

let timeLimit: TimeInterval = 0.01

func isTimeLimitExceeded(searchStartTime: TimeInterval) -> Bool {
    return Date().timeIntervalSince1970 - searchStartTime >= timeLimit
}
let MATE_VALUE = 50000
let PieceValueTable: [Int: Int] = [
    Piece.ColoredPieces.empty.rawValue : 0,
    Piece.ColoredPieces.whitePawn.rawValue : 100,
    Piece.ColoredPieces.whiteKnight.rawValue : 320,
    Piece.ColoredPieces.whiteBishop.rawValue : 330,
    Piece.ColoredPieces.whiteRook.rawValue : 500,
    Piece.ColoredPieces.whiteQueen.rawValue : 900,
    Piece.ColoredPieces.whiteKing.rawValue : 20000,
    
    Piece.ColoredPieces.blackPawn.rawValue : -100,
    Piece.ColoredPieces.blackKnight.rawValue : -320,
    Piece.ColoredPieces.blackBishop.rawValue : -330,
    Piece.ColoredPieces.blackRook.rawValue : -500,
    Piece.ColoredPieces.blackQueen.rawValue : -900,
    Piece.ColoredPieces.blackKing.rawValue : -20000,
]
func countMaterial(bitboards: [Int: Bitboard]) -> Int {
    var whiteSum = 0
    var blackSum = 0
    for (piece, bitboard) in bitboards where piece > 0 {
        let table = PieceSquareTables.getTable(piece: piece)
        let pieceValue = PieceValueTable[piece] ?? 0
        var bitboardCopy = bitboard
        while bitboardCopy != 0 {
            let position = Bitboard.popLSB(&bitboardCopy)
            if Piece.checkColor(piece: piece) == .white {
                whiteSum += pieceValue + table[position]
            } else {
                blackSum += pieceValue - table[position]
            }
        }
    }
    return whiteSum + blackSum
}

func evaluate(bitboards: [Int: Bitboard]) -> Int {
    return countMaterial(bitboards: bitboards)
}

func alphabeta(game: Game, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool) -> Int {
    var alpha = alpha
    var beta = beta

    if depth == 0 {
        
        if game.boardState.currentValidMoves.isEmpty {
            if isWhiteKingChecked(boardState: game.boardState) {
                return MATE_VALUE
            } else if isBlackKingChecked(boardState: game.boardState) {
                return -MATE_VALUE
            } else {
                return 0 //draw
            }
        }
        return evaluate(bitboards: game.boardState.bitboards)
    }
//    let moves = generateAllLegalMoves(boardState: game.boardState).sorted(by: >)
    let moves = game.boardState.currentValidMoves
    if maximizingPlayer {
        var maxEval = Int.min
        for move in moves {
            game.makeMove(move: move)
            let eval = alphabeta(game: game, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: false)
            game.undoMove()

            maxEval = max(maxEval, eval)
            alpha = max(alpha, maxEval)
            if beta <= alpha {
                break
            }
        }
        return maxEval
    } else {
        var minEval = Int.max
        for move in moves {
            game.makeMove(move: move)
            let eval = alphabeta(game: game, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: true)
            game.undoMove()

            minEval = min(minEval, eval)
            beta = min(beta, minEval)
            if beta <= alpha {
                break
            }
        }
        return minEval
    }
}

func findBestMove(game: Game, depth: Int, maximizingPlayer: Bool) -> Move? {
    return iterativeDeepening(game: game, initialDepth: depth, maximizingPlayer: maximizingPlayer)
}

func iterativeDeepening(game: Game, initialDepth: Int, maximizingPlayer: Bool) -> Move? {
    let searchStartTime = Date().timeIntervalSince1970
    var bestMove: Move? = nil
    var bestEval = maximizingPlayer ? Int.min : Int.max

    for depth in initialDepth...100 {
        if isTimeLimitExceeded(searchStartTime: searchStartTime) {
            break
        }
        let (move, eval) = performSearch(game: game, depth: depth, maximizingPlayer: maximizingPlayer)
        if maximizingPlayer {
            if eval > bestEval {
                bestEval = eval
                bestMove = move
            }
        } else {
            if eval < bestEval {
                bestEval = eval
                bestMove = move
            }
        }

//        print("Depth: \(depth), Best Move: \(String(describing: bestMove?.moveToNotation())), Evaluation: \(bestEval)")
    }

    return bestMove
}

func performSearch(game: Game, depth: Int, maximizingPlayer: Bool) -> (Move?, Int) {
    let legalMoves = generateAllLegalMoves(boardState: game.boardState).sorted(by: >)
    
    
    var bestMove: Move? = nil
    var alpha = Int.min
    var beta = Int.max
    var bestEval = maximizingPlayer ? Int.min : Int.max

    if maximizingPlayer {
        for move in legalMoves {
            game.makeMove(move: move)

            let eval = alphabeta(game: game, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: false)
            game.undoMove()

            if eval > bestEval {
                bestEval = eval
                bestMove = move
                alpha = max(alpha, bestEval)
            }

            if beta <= alpha {
                break
            }
        }
    } else {
        for move in legalMoves {
            game.makeMove(move: move)

            let eval = alphabeta(game: game, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: true)
            game.undoMove()

            if eval < bestEval {
                bestEval = eval
                bestMove = move
                beta = min(beta, bestEval)
            }

            if beta <= alpha {
                break
            }
        }
    }

    return (bestMove, bestEval)
}
//
//  PieceSquareTables.swift
//  Chessblazer
//
//  Created by sergiusz on 06/08/2024.
//

import Foundation

extension Array where Element == Int {
    func mirrored() -> [Int] {
        var mirroredTable = [Int]()
        for i in stride(from: 56, through: 0, by: -8) {
            mirroredTable.append(contentsOf: self[i..<i+8])
        }
        return mirroredTable
    }
}

struct PieceSquareTables {
    static func getTable(piece: Int, eval: Int = 0) -> [Int] {
        
        switch Piece.ColoredPieces(rawValue: piece) {

        case .some(.empty):
            return [Int]()
        case .some(.blackKing):
            return getKingTable(currentBoardEval: eval).mirrored()
        case .some(.blackPawn):
            return pawnTable.mirrored()
        case .some(.blackQueen):
            return queenTable.mirrored()
        case .some(.blackKnight):
            return knightTable.mirrored()
        case .some(.blackBishop):
            return bishopTable.mirrored()
        case .some(.blackRook):
            return rookTable.mirrored()
        case .some(.whiteKing):
            return getKingTable(currentBoardEval: eval)
        case .some(.whitePawn):
            return pawnTable
        case .some(.whiteQueen):
            return queenTable
        case .some(.whiteKnight):
            return knightTable
        case .some(.whiteBishop):
            return bishopTable
        case .some(.whiteRook):
            return rookTable
        case .none:
            return [Int]()
        }
        
    }
    
    static let pawnTable: [Int] = [
        0,  0,  0,  0,  0,  0,  0,  0,
        5, 10, 10,-20,-20, 10, 10,  5,
        5, -5,-10,  0,  0,-10, -5,  5,
        0,  0,  0, 20, 20,  0,  0,  0,
        5,  5, 10, 25, 25, 10,  5,  5,
        10, 10, 20, 30, 30, 20, 10, 10,
        50, 50, 50, 50, 50, 50, 50, 50,
        0,  0,  0,  0,  0,  0,  0,  0,
    ]
    
    static let knightTable: [Int] = [
        -50,-40,-30,-30,-30,-30,-40,-50,
         -40,-20,  0,  5,  5,  0,-20,-40,
         -30,  5, 10, 15, 15, 10,  5,-30,
         -30,  0, 15, 20, 20, 15,  0,-30,
         -30,  5, 15, 20, 20, 15,  5,-30,
         -30,  0, 10, 15, 15, 10,  0,-30,
         -40,-20,  0,  0,  0,  0,-20,-40,
         -50,-40,-30,-30,-30,-30,-40,-50,
    ]
    
    static let bishopTable: [Int] = [
        -20,-10,-10,-10,-10,-10,-10,-20,
         -10,  5,  0,  0,  0,  0,  5,-10,
         -10, 10, 10, 10, 10, 10, 10,-10,
         -10,  0, 10, 10, 10, 10,  0,-10,
         -10,  5,  5, 10, 10,  5,  5,-10,
         -10,  0,  5, 10, 10,  5,  0,-10,
         -10,  0,  5, 10, 10,  5,  0,-10,
         -20,-10,-10,-10,-10,-10,-10,-20,
    ]
    
    static let rookTable: [Int] = [
        0,  0,  0,  5,  5,  0,  0,  0,
        -5,  0,  0,  0,  0,  0,  0, -5,
        -5,  0,  0,  0,  0,  0,  0, -5,
        -5,  0,  0,  0,  0,  0,  0, -5,
        -5,  0,  0,  0,  0,  0,  0, -5,
        -5,  0,  0,  0,  0,  0,  0, -5,
        5, 10, 10, 10, 10, 10, 10,  5,
        0,  0,  0,  0,  0,  0,  0,  0,
    ]
    
    static let queenTable: [Int] = [
        -20,-10,-10, -5, -5,-10,-10,-20,
         -10,  0,  5,  0,  0,  0,  0,-10,
         -10,  5,  5,  5,  5,  5,  0,-10,
         0,  0,  5,  5,  5,  5,  0, -5,
         -5,  0,  5,  5,  5,  5,  0, -5,
         -10,  0,  5,  5,  5,  5,  0,-10,
         -10,  0,  0,  0,  0,  0,  0,-10,
         -20,-10,-10, -5, -5,-10,-10,-20,
    ]
    
    static let kingMidgameTable: [Int] = [
        20, 30, 10,  0,  0, 10, 30, 20,
        20, 20,  0,  0,  0,  0, 20, 20,
        -10,-20,-20,-20,-20,-20,-20,-10,
        -20,-30,-30,-40,-40,-30,-30,-20,
        -30,-40,-40,-50,-50,-40,-40,-30,
        -30,-40,-40,-50,-50,-40,-40,-30,
        -30,-40,-40,-50,-50,-40,-40,-30,
        -30,-40,-40,-50,-50,-40,-40,-30,
    ]
    
    static let kingEndgameTable: [Int] = [
        0,  10,  20,  30,  30,  20,  10,   0,
       10,  20,  30,  40,  40,  30,  20,  10,
       20,  30,  40,  50,  50,  40,  30,  20,
       30,  40,  50,  60,  60,  50,  40,  30,
       30,  40,  50,  60,  60,  50,  40,  30,
       20,  30,  40,  50,  50,  40,  30,  20,
       10,  20,  30,  40,  40,  30,  20,  10,
        0,  10,  20,  30,  30,  20,  10,   0
    ]
    
    static func getKingTable(currentBoardEval: Int) -> [Int] {
//        for now 2000 should be enogh
        if abs(currentBoardEval) < 2000 {
            return kingEndgameTable
        } else {
            return kingMidgameTable
        }
    }
    
}
//
//  Board.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation
import SwiftUI

class Game {
    
    var boardData = BoardData()
    var boardState = BoardState(currentTurnColor: .white)
    
    init() {
        startNewGame()
    }
    
    func loadFromFen(fen: String) {
        boardState = GameEngine.loadBoardFromFen(fen: fen)
        boardState.currentValidMoves = generateAllLegalMoves(boardState: boardState)
        boardState.attackBitboard = generateAllAttackedSquares(bitboards: boardState.bitboards, currentColor: boardState.currentTurnColor)
    }
    
    func startNewGame() {
        loadFromFen(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }
    
    func makeMove(move: Move) {
        
        boardState.performedMovesList.append(
            MoveData(
                piece: move.pieceValue,
                turn: 0,
                color: boardState.currentTurnColor,
                move: move,
                capturedPiece: move.captureValue,
                bitboards: boardState.bitboards,
                castles: boardState.castlesAvailable,
                currentValidMoves: boardState.currentValidMoves,
                attackBitboard: boardState.attackBitboard
            ))
        
        
        boardState = GameEngine.makeMove(boardState: boardState, move: move)
        boardState.currentTurnColor = boardState.currentTurnColor.getOppositeColor()
        boardState.currentValidMoves = generateAllLegalMoves(boardState: boardState)
        boardState.attackBitboard = generateAllAttackedSquares(bitboards: boardState.bitboards, currentColor: boardState.currentTurnColor)
        
        
        if boardState.currentValidMoves.isEmpty {
            if isWhiteKingChecked(boardState: boardState) {
                boardData.gameResult = .black
            } else if isBlackKingChecked(boardState: boardState) {
                boardData.gameResult = .white
            } else {
                boardData.gameResult = .none
            }
        }
    }
    
    func undoMove() {
        guard let moveData = boardState.performedMovesList.popLast() else { return }
        boardState.bitboards = moveData.bitboards
        boardState.castlesAvailable = moveData.castles
        boardState.currentTurnColor = moveData.color
        boardState.currentValidMoves = moveData.currentValidMoves
        boardState.attackBitboard = moveData.attackBitboard
        
        
        if !boardState.currentValidMoves.isEmpty {
            boardData.hasGameEnded = false
            boardData.gameResult = .none
        }
    }
        
    private func toBitboardsRepresentation(array: [Int]) -> [Piece.ColoredPieces.RawValue : Bitboard] {
        var bitboards = [Piece.ColoredPieces.RawValue : Bitboard]()
        
        for (index, piece) in array.enumerated() {
            if piece > 0 {
                bitboards[piece] = (bitboards[piece] ?? Bitboard(0)) | (Bitboard(1) << Bitboard(UInt64(index)))
            }
        }
        return bitboards
    }
    
    func findMove(notation: String) -> Move {
        var move = Move(notation: notation)
        
        var found = boardState.currentValidMoves.first(where: {
            $0.fromSquare == move.fromSquare && $0.targetSquare == move.targetSquare
        })
        return found!
    }
    
    
    func toBoardArrayRepresentation() -> [Int] {
        var array = Array(repeating: 0, count: 64)
        let copy = boardState.bitboards
        
        for bitboard in copy {
            var pieceBitboard = bitboard.value
            while pieceBitboard != 0 {
                let piece = bitboard.key
                let index = Bitboard.popLSB(&pieceBitboard)
                
                array[index] = piece
            }
        }
        return array
    }
}
//
//  GameEngine.swift
//  Chessblazer
//
//  Created by sergiusz on 11/10/2024.
//

import Foundation

class GameEngine {
    
    static func makeMove(boardState: BoardState, move: Move) -> BoardState {
        
        var boardStateCopy = boardState
        
        let from = move.fromSquare!
        let target = move.targetSquare!
        
        let pieceValue = move.pieceValue
        
        if move.castling {
            boardStateCopy.bitboards = GameEngine.makeMoveOperations(bitboards: boardStateCopy.bitboards, pieceValue: pieceValue, from: from, target: move.castlingKingDestination)
            boardStateCopy.bitboards = GameEngine.makeMoveOperations(bitboards: boardStateCopy.bitboards, pieceValue: move.captureValue, from: target, target: move.castlingRookDestination)
            
            if pieceValue == Piece.ColoredPieces.whiteKing.rawValue {
                boardStateCopy.castlesAvailable.remove("K")
                boardStateCopy.castlesAvailable.remove("Q")
            } else if pieceValue == Piece.ColoredPieces.blackKing.rawValue {
                boardStateCopy.castlesAvailable.remove("k")
                boardStateCopy.castlesAvailable.remove("q")
            }
            
        } else if move.promotionPiece != 0 {
            let newPiece = move.promotionPiece
            let captureValue = move.captureValue

            var pawnBitboard = boardStateCopy.bitboards[pieceValue]!
            pawnBitboard = pawnBitboard & ~(Bitboard(1) << Bitboard(from))
            var newPieceBitboard = boardStateCopy.bitboards[newPiece]!
            newPieceBitboard = newPieceBitboard | (Bitboard(1) << Bitboard(target))
            boardStateCopy.bitboards[newPiece] = newPieceBitboard
            boardStateCopy.bitboards[pieceValue] = pawnBitboard

            if captureValue != 0 {
                var captureBitboard = boardStateCopy.bitboards[captureValue]!
                captureBitboard = captureBitboard & ~(Bitboard(1) << Bitboard(target))
                boardStateCopy.bitboards[captureValue] = captureBitboard
            }

            
            
        } else if move.enPasssantCapture != 0 {
            boardStateCopy.bitboards = GameEngine.makeMoveOperations(bitboards: boardStateCopy.bitboards, pieceValue: pieceValue, from: from, target: target)
            let enPassantCapture = move.enPasssantCapture
            let captured = move.captureValue
            boardStateCopy.bitboards[captured] = boardStateCopy.bitboards[captured]! & ~Bitboard(1 << enPassantCapture)
        } else {
            boardStateCopy.bitboards = GameEngine.makeMoveOperations(bitboards: boardStateCopy.bitboards, pieceValue: pieceValue, from: from, target: target)
            
            switch pieceValue {
            case Piece.ColoredPieces.whiteKing.rawValue:
                boardStateCopy.castlesAvailable.remove("K")
                boardStateCopy.castlesAvailable.remove("Q")
                
            case Piece.ColoredPieces.blackKing.rawValue:
                boardStateCopy.castlesAvailable.remove("k")
                boardStateCopy.castlesAvailable.remove("q")
                
            case Piece.ColoredPieces.whiteRook.rawValue:
                if from == 0 {
                    boardStateCopy.castlesAvailable.remove("Q")
                } else if from == 7 {
                    boardStateCopy.castlesAvailable.remove("K")
                }
            case Piece.ColoredPieces.blackRook.rawValue:
                if from == 56 {
                    boardStateCopy.castlesAvailable.remove("q")
                } else if from == 63 {
                    boardStateCopy.castlesAvailable.remove("k")
                }
            default:
                break
            }
        }
//        boardStateCopy.attackBitboard = generateAllAttackedSquares(bitboards: boardStateCopy.bitboards, currentColor: boardStateCopy.currentTurnColor)
        return boardStateCopy
    }
    
    
    
    static func makeMoveOnly(boardState: BoardState, move: Move) -> BoardState {
        
        var boardStateCopy = boardState
        
        let from = move.fromSquare!
        let target = move.targetSquare!
        
        let pieceValue = move.pieceValue
        
        if move.castling {
            
            boardStateCopy.bitboards = GameEngine.makeMoveOperations(bitboards: boardStateCopy.bitboards, pieceValue: pieceValue, from: from, target: move.castlingKingDestination)
            boardStateCopy.bitboards = GameEngine.makeMoveOperations(bitboards: boardStateCopy.bitboards, pieceValue: move.captureValue, from: target, target: move.castlingRookDestination)
            
            if pieceValue == Piece.ColoredPieces.whiteKing.rawValue {
                boardStateCopy.castlesAvailable.remove("K")
                boardStateCopy.castlesAvailable.remove("Q")
            } else if pieceValue == Piece.ColoredPieces.blackKing.rawValue {
                boardStateCopy.castlesAvailable.remove("k")
                boardStateCopy.castlesAvailable.remove("q")
            }
        }  else if move.promotionPiece != 0 {
            let newPiece = move.promotionPiece
            let captureValue = move.captureValue

            var pawnBitboard = boardStateCopy.bitboards[pieceValue]!
            pawnBitboard = pawnBitboard & ~(Bitboard(1) << Bitboard(from))
            var newPieceBitboard = boardStateCopy.bitboards[newPiece]!
            newPieceBitboard = newPieceBitboard | (Bitboard(1) << Bitboard(target))
            boardStateCopy.bitboards[newPiece] = newPieceBitboard
            boardStateCopy.bitboards[pieceValue] = pawnBitboard

            if captureValue != 0 {
                var captureBitboard = boardStateCopy.bitboards[captureValue]!
                captureBitboard = captureBitboard & ~(Bitboard(1) << Bitboard(target))
                boardStateCopy.bitboards[captureValue] = captureBitboard
            }

            
        } else if move.enPasssantCapture != 0 {
            boardStateCopy.bitboards = GameEngine.makeMoveOperations(bitboards: boardStateCopy.bitboards, pieceValue: pieceValue, from: from, target: target)
            let enPassantCapture = move.enPasssantCapture
            let captured = move.captureValue
            boardStateCopy.bitboards[captured] = boardStateCopy.bitboards[captured]! & ~Bitboard(1 << enPassantCapture)
        } else {
            
            boardStateCopy.bitboards = GameEngine.makeMoveOperations(bitboards: boardStateCopy.bitboards, pieceValue: pieceValue, from: from, target: target)
            
            switch pieceValue {
            case Piece.ColoredPieces.whiteKing.rawValue:
                boardStateCopy.castlesAvailable.remove("K")
                boardStateCopy.castlesAvailable.remove("Q")
                
            case Piece.ColoredPieces.blackKing.rawValue:
                boardStateCopy.castlesAvailable.remove("k")
                boardStateCopy.castlesAvailable.remove("q")
                
            case Piece.ColoredPieces.whiteRook.rawValue:
                if from == 0 {
                    boardStateCopy.castlesAvailable.remove("Q")
                } else if from == 7 {
                    boardStateCopy.castlesAvailable.remove("K")
                }
            case Piece.ColoredPieces.blackRook.rawValue:
                if from == 56 {
                    boardStateCopy.castlesAvailable.remove("q")
                } else if from == 63 {
                    boardStateCopy.castlesAvailable.remove("k")
                }
            default:
                break
            }
        }
        boardStateCopy.attackBitboard = generateAllAttackedSquares(bitboards: boardStateCopy.bitboards, currentColor: boardStateCopy.currentTurnColor)
        return boardStateCopy
    }

    
    static func makeMoveOperations(bitboards: [Int: Bitboard], pieceValue: Int, from: Int, target: Int) -> [Int: Bitboard] {
        var bitboardsCopy = bitboards
        var bitboard = bitboardsCopy[pieceValue]! //it's expected to cause exception if something is wrong in code before
        bitboard = bitboard & ~(Bitboard(1) << Bitboard(from))
        bitboard = bitboard | (Bitboard(1) << Bitboard(target))
        bitboardsCopy[pieceValue] = bitboard
        for (key, value) in bitboardsCopy {
            if (key != pieceValue) && (value & (Bitboard(1) << Bitboard(target))) != 0 {
                bitboardsCopy[key] = bitboardsCopy[key]! & ~(Bitboard(1) << Bitboard(target))
                break
            }
        }
        return bitboardsCopy
    }
    
    static func loadBoardFromFen(fen: String) -> BoardState {
        var boardState = BoardState(currentTurnColor: .white)
        let args = fen.components(separatedBy: " ")
        boardState.currentTurnColor = args[1] == "w" ? .white : .black
        boardState.castlesAvailable.removeAll()
        for letter in args[2] {
            if letter == "-" { break } else {boardState.castlesAvailable.insert(letter)}
        }
        boardState.enPassant = args[3]
        let ranks: [String] = args[0].components(separatedBy: "/")
        var index = 0
        for rank in ranks.reversed() {
            
            for char in rank {
                if char.isNumber {
                    for _ in 0..<char.wholeNumberValue! {
                        index+=1
                    }
                } else {
                    let piece: Int = Piece.combine(type: Piece.PiecesDict[char.lowercased().first!] ?? Piece.PieceType.empty, color: char.isUppercase ? Piece.Color.white : Piece.Color.black)
                    
                    boardState.bitboards[piece] = (boardState.bitboards[piece] ?? Bitboard(0)) | (Bitboard(1) << Bitboard(UInt64(index)))
                    index+=1
                }
            }
        }
        
        return boardState
    }
}
//
//  Magic.swift
//  Chessblazer
//
//  Created by sergiusz on 30/07/2024.
//

import Foundation

class Magic {
    
    static func whitePiecesBitboards(bitboards: [Int: Bitboard]) -> Bitboard {
        var bitboard = Bitboard(0)
        
        for board in bitboards {
            if Piece.checkColor(piece: board.key) == .white {
                bitboard = bitboard | board.value
            }
        }
        return bitboard
    }
    
    static func blackPiecesBitboards(bitboards: [Int: Bitboard]) -> Bitboard {
        var bitboard = Bitboard(0)
        
        for board in bitboards {
            if Piece.checkColor(piece: board.key) == .black {
                bitboard = bitboard | board.value
            }
        }
        return bitboard
    }
    
    static func allPieces(bitboards: [Int: Bitboard]) -> Bitboard {
        return whitePiecesBitboards(bitboards: bitboards) | blackPiecesBitboards(bitboards: bitboards)
    }
    
    
    static func createAllBlockers(movementMask: Bitboard) -> [Bitboard] {
        
        var indexesToCheck = [Int]()
        var mask = movementMask
        
        while mask != 0 {
            indexesToCheck.append(Bitboard.popLSB(&mask))
        }
        
        
        let numberOfDiffBitboards = 1 << indexesToCheck.count // 2^n
        var blockers = Array(repeating: Bitboard(0), count: numberOfDiffBitboards)
        
        for patternIndex in 0..<numberOfDiffBitboards {
            for bitIndex in 0..<indexesToCheck.count {
                let bit = (patternIndex >> bitIndex) & 1
                blockers[patternIndex] = blockers[patternIndex] | (Bitboard(bit) << Bitboard(indexesToCheck[bitIndex]))
            }
        }
        return blockers
    }
    


}
//protocol Slider {
//    static var lookUpTable: [Int: [UInt64: Bitboard]] {get set}
//    static var masks: [Bitboard] {get set}
//    static func createLegalMoves(square: Int, blocker: Bitboard) -> Bitboard
//}

enum Slider {
    case rook(Rook)
    case bishop(Bishop)
}


//
//  MagicBishop.swift
//  Chessblazer
//
//  Created by sergiusz on 06/09/2024.
//

import Foundation

let bishopMagics: [UInt64] = [9530267746158843920, 36206101892700160, 310749199225323561, 1154051806998317324, 288513161097656322, 1225265250907987968, 576500352439156768, 18139745251492096, 9223373282533720336, 290822201970817, 9223706496027598848, 551987185680, 581642187964480, 276102807553, 4611759896294146048, 9223394577120100642, 9225764600229790208, 281544115751940, 70508339003780, 176007894090752, 35185446912002, 8937896158208, 613052508020945152, 9224726637394817088, 1691083262136640, 141031727449092, 1152925902691108992, 4423817363616, 70394581131264, 1729523132040552448, 342344219664320512, 11531537286609065984, 4508014855848064, 281758715085088, 1154047414714253472, 1297037105670655232, 633593860727040, 1153098526054416896, 88579674538240, 288828656506159168, 1126741921775616, 21999359369472, 4611704194863235328, 4616189626653345832, 4653201995337856, 35807154935296, 4507997808623696, 1266777015714120, 577589409714110976, 216736831755124816, 1585834434081407488, 1441156279174184960, 36031008122077184, 11529223846798297128, 18174946601601024, 9631998901551808, 4611759825364847105, 82195232997245186, 4400294674714, 109951163434512, 151015723588699136, 565175183737088, 5188463432512439296, 3993499317833920]
let bishopShifts: [Int] = [57, 57, 57, 57, 57, 57, 57, 57, 57, 55, 55, 55, 55, 55, 55, 57, 57, 55, 53, 53, 53, 53, 55, 57, 57, 55, 53, 51, 51, 53, 55, 57, 57, 55, 53, 51, 51, 53, 55, 57, 57, 55, 53, 53, 53, 53, 55, 57, 57, 55, 55, 55, 55, 55, 55, 57, 57, 57, 57, 57, 57, 57, 57, 57]

class Bishop {
    static let masks: [Bitboard] = generateBishopMasks()
    
    static let lookUpTable: [Int: [UInt64: Bitboard]] = createBishopLookupTable()

    static func generateBishopMask(square: Int) -> Bitboard {
        let rank = square / 8
        let file = square % 8
        var mask = Bitboard(0)
        for offset in 1..<8 {
            // NE
            if rank + offset < 8 && file + offset < 8 {
                mask = mask | Bitboard(1) << Bitboard(((rank + offset) * 8 + (file + offset)))
            }
            // NW
            if rank + offset < 8 && file - offset >= 0 {
                mask = mask | Bitboard(1) << Bitboard((rank + offset) * 8 + (file - offset))
            }
            // SE
            if rank - offset >= 0 && file + offset < 8 {
                mask = mask | Bitboard(1) << Bitboard((rank - offset) * 8 + (file + offset))
            }
            // SW
            if rank - offset >= 0 && file - offset >= 0 {
                mask = mask | Bitboard(1) << Bitboard((rank - offset) * 8 + (file - offset))
            }
        }
        
        return mask
    }
    
    static func generateBishopMasks() -> [Bitboard] {
        var bishopMasks: [Bitboard] = Array(repeating: Bitboard(0), count: 64)
        for squareIndex in 0...63 {
            bishopMasks[squareIndex] = generateBishopMask(square: squareIndex)
        }
        return bishopMasks
    }
    
    static func hashKeyBishop(blockerBitboard: Bitboard, square: Int) -> UInt64 {
        let magic = bishopMagics[square]
        let shift = bishopShifts[square]
        let of = blockerBitboard.multipliedReportingOverflow(by: magic)
        return (of.0) >> shift
    }
    
    static func createBishopLookupTable() -> [Int: [UInt64: Bitboard]] {
        var bishopMovesLookup: [Int: [UInt64: Bitboard]] = [:]
        
        
        for square in 0...63 {
            bishopMovesLookup[square] = [:]
            let movementMask = masks[square] //ok
            let blockers = Magic.createAllBlockers(movementMask: movementMask) // raczej ok

            for blocker in blockers {
                let legalMoves: Bitboard = createLegalMoves(square: square, blocker: blocker)
                bishopMovesLookup[square]![hashKeyBishop(blockerBitboard: blocker, square: square)] = legalMoves
            }
        }
        return bishopMovesLookup
    }
    

    static func createLegalMoves(square: Int, blocker: Bitboard) -> Bitboard {
        var legalMoves = Bitboard(0)
        
        // NE, NW, SE, SW directions
        let directions: [(Int, Int)] = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
        
        for (deltaRow, deltaCol) in directions {
            var currentRow = square / 8
            var currentCol = square % 8
            
            while true {
                currentRow += deltaRow
                currentCol += deltaCol
                
                if currentRow < 0 || currentRow >= 8 || currentCol < 0 || currentCol >= 8 {
                    break
                }
                
                let newSquare = currentRow * 8 + currentCol
                legalMoves = Bitboard(legalMoves | 1 << newSquare)
                
                if (blocker & (1 << newSquare)) != 0 {
                    break
                }
            }
        }
        
        return legalMoves
    }
}
//
//  MagicGeneration.swift
//  Chessblazer
//
//  Created by sergiusz on 06/09/2024.
//

import Foundation
#warning("to refactor")
//func findMagic<S: Slider>(slider: S.Type, magics: inout [UInt64], shifts: inout [Int]) {
//    for square in 0...63 {
//        let mask = slider.masks[square]
//        let blockers = Magic.createAllBlockers(movementMask: mask)
//        let bits = mask.nonzeroBitCount
//        let shift = 64 - bits
//        
//        while true {
//            let magic = UInt64.random(in: UInt64.min...UInt64.max) &
//                        UInt64.random(in: UInt64.min...UInt64.max) &
//                        UInt64.random(in: UInt64.min...UInt64.max)
//            if testMagic(slider: slider, square: square, shift: shift, magic: magic, blockers: blockers) {
//                print("founded magic: \(magic) shift: \(shift) for square \(square)")
//                magics[square] = magic
//                shifts[square] = shift
//                break
//            }
//        }
//    }
//}
//
//func testMagic<S: Slider>(slider: S.Type, square: Int, shift: Int, magic: UInt64, blockers: [Bitboard]) -> Bool {
//    var table = [UInt64: Bitboard]()
//    for blocker in blockers {
//        let mask = slider.masks[square]
//        let moves = slider.createLegalMoves(square: square, blocker: blocker & mask)
//        let index = magicIndex(magic: magic, shift: shift, blocker: blocker & mask)
//        if let existingMoves = table[index] {
//            if existingMoves != moves {
//                return false
//            }
//        } else {
//            table[index] = moves
//        }
//    }
//    return true
//}

func magicIndex(magic: UInt64, shift: Int, blocker: Bitboard) -> UInt64 {
    let hash = blocker.multipliedReportingOverflow(by: magic)
    return hash.0 >> shift
}


#warning("to refactor after swift 6 migration")
//func generateMagics() {
//    var rookShifts: [Int] = Array(repeating: 0, count: 64)
//    var rookMagics: [UInt64] = Array(repeating: 0, count: 64)
//    
//    var bishopMagics: [UInt64] = Array(repeating: 0, count: 64)
//    var bishopShifts: [Int] = Array(repeating: 0, count: 64)
//    
//    findMagic(slider: Rook.self, magics: &rookMagics, shifts: &rookShifts)
//    findMagic(slider: Bishop.self, magics: &bishopMagics, shifts: &bishopShifts)
//    
//    outputMagic(name: "rookShifts", array: rookShifts)
//    outputMagic(name: "rookMagics", array: rookMagics)
//
//    outputMagic(name: "bishopShifts", array: bishopShifts)
//    outputMagic(name: "bishopMagics", array: bishopMagics)
//}

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
//
//  MagicRook.swift
//  Chessblazer
//
//  Created by sergiusz on 06/09/2024.
//

import Foundation


let rookShifts: [Int] = [52, 52, 52, 52, 52, 52, 52, 52, 52, 53, 53, 53, 53, 53, 53, 52, 52, 53, 53, 53, 53, 53, 53, 52, 52, 53, 53, 53, 53, 53, 53, 52, 52, 53, 53, 53, 53, 53, 53, 52, 52, 53, 53, 53, 53, 53, 53, 52, 52, 53, 53, 53, 53, 53, 53, 52, 52, 52, 52, 52, 52, 52, 52, 52]
let rookMagics: [UInt64] = [612489824209895456, 90073229503234056, 72067764789223424, 72075187465756680, 36033195082651648, 4971987182891205890, 288240925673783568, 108087490581165184, 1266637718159648, 2308165188777943042, 2955539331944448, 140806208356356, 140771848225792, 291045332144490497, 14636767517348866, 3504363462530826305, 36187676470149669, 1887289753242443812, 4611798168756031552, 387036685026304, 144837567291201536, 9224799203023212552, 10430341135050211593, 72921810179492612, 211108380057616, 5982064535803011072, 4574084336721920, 1153502048894060546, 76640360650244098, 1728434426478609, 4638718765927500945, 9225062286874386500, 5242192440454023200, 685743420878102528, 1482036808337328145, 2341889398502596616, 2267826620416, 16888791390224896, 432354465614401040, 36099441345692545, 360305700888936448, 288247971022127104, 621496997953699872, 1153502046880563204, 4582764665995266, 2256301216628737, 244338258870534184, 18014965483044865, 18155144860541184, 9223407841862223104, 14707205023994112, 154069335288064, 9438207846645888, 45150415830123008, 722833796149806080, 1441153882255270144, 1162212927621570577, 292745039061121, 9302143785895953, 1152939096936808993, 4501128875537, 5769111827054069762, 328764010856973700, 9260949496605757698]

class Rook {
    static let masks: [Bitboard] = generateRookMasks()
    static let lookUpTable = createRookLookupTable()
    
    static func generateRookMask(square: Int) -> Bitboard {
        
        let rank = square / 8
        let file = square % 8
        
        var rankMask = Bitboard.Masks.rank1 << (Bitboard(rank * 8))
        var fileMask = Bitboard.Masks.fileA << Bitboard(file)
        rankMask = rankMask & ~(Bitboard.Masks.fileA | Bitboard.Masks.fileH)
        fileMask = fileMask & ~(Bitboard.Masks.rank1 | Bitboard.Masks.rank8)
        return rankMask | fileMask
    }
    
    static func generateRookMasks() -> [Bitboard] {
        var rookMasks: [Bitboard] = Array(repeating: Bitboard(0), count: 64)
        for squareIndex in 0...63 {
            rookMasks[squareIndex] = generateRookMask(square: squareIndex)
        }
        return rookMasks
    }
    

    static func hashKeyRook(blockerBitboard: Bitboard, square: Int) -> UInt64 {
        let mask = masks[square]
        let maskedBlockers = blockerBitboard & mask
        let magic = rookMagics[square]
        let shift = rookShifts[square]
        let of = maskedBlockers.multipliedReportingOverflow(by: magic)
        return (of.0) >> shift
    }

    
    static func createLegalMoves(square: Int, blocker: Bitboard) -> Bitboard {
        var legalMoves = Bitboard(0)
        
        let rank = square / 8
        let file = square % 8
        
        // North
        for r in (0..<rank).reversed() {
            let targetSquare = r * 8 + file
            legalMoves = legalMoves | Bitboard(1) << Bitboard(targetSquare)
            if (blocker & (1 << targetSquare)) != 0 {
                break
            }
        }
        
        // South
        for r in (rank+1..<8) {
            let targetSquare = r * 8 + file
            legalMoves = legalMoves | Bitboard(1) << Bitboard(targetSquare)
            if (blocker & (1 << targetSquare)) != 0 {
                break
            }
        }
        
        // West
        for f in (0..<file).reversed() {
            let targetSquare = rank * 8 + f
            legalMoves = legalMoves | Bitboard(1) << Bitboard(targetSquare)
            if (blocker & (1 << targetSquare)) != 0 {
                break
            }
        }
        
        // East
        for f in (file+1..<8) {
            let targetSquare = rank * 8 + f
            legalMoves = legalMoves | Bitboard(1) << Bitboard(targetSquare)
            if (blocker & (1 << targetSquare)) != 0 {
                break
            }
        }
        return legalMoves
    }
    static func createRookLookupTable() -> [Int: [UInt64: Bitboard]] {
        var rookMovesLookup: [Int: [UInt64: Bitboard]] = [:]
        for square in 0...63 {
            rookMovesLookup[square] = [:]
            let movementMask = masks[square]
            let blockers = Magic.createAllBlockers(movementMask: movementMask)

            for blocker in blockers {
                let legalMoves: Bitboard = createLegalMoves(square: square, blocker: blocker)
                let key = hashKeyRook(blockerBitboard: blocker, square: square)
                rookMovesLookup[square]![key] = legalMoves
            }
        }
        return rookMovesLookup
    }
}
//
//  GenerateMoves.swift
//  Chessblazer
//
//  Created by sergiusz on 30/07/2024.
//

import Foundation



func generateAllPossibleMoves(bitboards: [Int: Bitboard], currentColor: Piece.Color, moves: inout [Move], lastMove: Move?, castlesAvailable: Set<Character>) {
    
    moves.removeAll()
    
    
    if let lastMove = lastMove {
        moves.append(contentsOf: enPassantCheck(bitboards: bitboards, lastMove: lastMove))
    }
    
    
    for bitboard in bitboards {
        if Piece.checkColor(piece: bitboard.key) == currentColor {
            var pieceSquares = [Int]()
            var copyBitboard: Bitboard = bitboard.value
            
            while copyBitboard != 0 {
                pieceSquares.append(Bitboard.popLSB(&copyBitboard))
            }
            let pieceType = Piece.getType(piece: bitboard.key)
            

            
            for square in pieceSquares {
                switch pieceType {
                case .queen:
                    generateQueenMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves)
                case .bishop:
                    generateBishopMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves)
                case .rook:
                    generateRookMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves)
                case .pawn:
                    generatePawnMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves)
                case .king:
                    generateKingMovesBitboard(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves)
                    generateCastles(bitboards: bitboards, currentColor: currentColor, moves: &moves, castlesAvailable: castlesAvailable)

                case .knight:
                    generateKnightMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &moves)
                    
                default:
                    print("\(pieceType) is not found while generating moves")
                    
                }
            }
        }
    }
}

func generateAllAttackedSquares(bitboards: [Int: Bitboard], currentColor: Piece.Color) -> Bitboard {
    let enemyColor = currentColor.getOppositeColor()
    var attackBitboard = Bitboard(0)
    let friendlyBitboard = currentColor == .black ? Magic.whitePiecesBitboards(bitboards: bitboards) : Magic.blackPiecesBitboards(bitboards: bitboards)
    var pawnAttackBitboard = Bitboard(0)
    for bitboard in bitboards {
        if Piece.checkColor(piece: bitboard.key) == enemyColor {
            var pieceSquares = [Int]()
            var copyBitboard: Bitboard = bitboard.value
            
            while copyBitboard != 0 {
                pieceSquares.append(Bitboard.popLSB(&copyBitboard))
            }
            let pieceType = Piece.getType(piece: bitboard.key)
            
            for square in pieceSquares {
                switch pieceType {
                case .queen:
                    attackBitboard = attackBitboard | generateQueenAttacks(bitboards: bitboards, square: square, friendlyBitboard: friendlyBitboard)
                    
                case .bishop:
                    attackBitboard = attackBitboard | generateBishopAttacks(bitboards: bitboards, square: square, friendlyBitboard: friendlyBitboard)
                    
                case .rook:
                    attackBitboard = attackBitboard | generateRookAttacks(bitboards: bitboards, square: square, friendlyBitboard: friendlyBitboard)
                case .pawn:
                    pawnAttackBitboard = generatePawnAttacks(currentColor: currentColor.getOppositeColor(), square: square)
                    attackBitboard = attackBitboard | pawnAttackBitboard
                    
                case .king:
                    attackBitboard = attackBitboard | generateKingAttacks(square: square, friendlyBitboard: friendlyBitboard)
                    
                case .knight:
                    attackBitboard = attackBitboard | generateKnightAttacks(square: square, friendlyBitboard: friendlyBitboard)
                    
                default:
                    print("\(pieceType) is not found while generating attackBitboard")
                    
                }
            }
        }
    }
    return attackBitboard
}

func generateAllLegalMoves(boardState: BoardState) -> [Move] {
    
    var possibleMoves = [Move]()
    var legalMoves = [Move]()
    let lastMove: Move? = boardState.performedMovesList.last?.move
    generateAllPossibleMoves(bitboards: boardState.bitboards, currentColor: boardState.currentTurnColor, moves: &possibleMoves, lastMove: lastMove, castlesAvailable: boardState.castlesAvailable)

    
    for move in possibleMoves {
        let newState = GameEngine.makeMoveOnly(boardState: boardState, move: move)
        if !checkIfCheck(boardState: newState) {
            legalMoves.append(move)
        }
    }
    
    return legalMoves
}
//
//  GeneratorUtils.swift
//  Chessblazer
//
//  Created by sergiusz on 10/10/2024.
//

import Foundation
func emptySquaresBitboard(bitboards: [Int: Bitboard]) -> Bitboard {
    var notEmpty = Bitboard(0)
    for bitboard in bitboards {
        notEmpty = notEmpty | bitboard.value
    }
    
    return ~notEmpty
}

func getKingPosition(bitboards: [Int: Bitboard], color: Piece.Color) -> Int {
    
    if color == .white {
        var b = bitboards[Piece.ColoredPieces.whiteKing.rawValue]!
        let square = Bitboard.popLSB(&b)
        return square
    } else {
        var b = bitboards[Piece.ColoredPieces.blackKing.rawValue]!
        let square = Bitboard.popLSB(&b)
        return square
    }
}

func getKingBitboard(bitboards: [Int: Bitboard], color: Piece.Color) -> Bitboard {
    
    if color == .white {
        return bitboards[Piece.ColoredPieces.whiteKing.rawValue]!
    } else {
        return bitboards[Piece.ColoredPieces.blackKing.rawValue]!
    }
    
}

func getPieceValueFromField(at field: Int, bitboards: [Piece.ColoredPieces.RawValue: Bitboard]) -> Piece.ColoredPieces.RawValue {
    let b = Bitboard(1) << Bitboard(field)
    for bitboard in bitboards {
        if b & bitboard.value == b {
            return bitboard.key
        }
    }
    return 0 // no capture
}

func checkIfCheck(boardState: BoardState) -> Bool {
    let attackTable = boardState.attackBitboard
    let kingBitboard = getKingBitboard(bitboards: boardState.bitboards, color: boardState.currentTurnColor)
    return (attackTable & kingBitboard) != 0
}

func isWhiteKingChecked(boardState: BoardState) -> Bool {
    let attackTable = generateAllAttackedSquares(bitboards: boardState.bitboards, currentColor: .white)
    let kingBitboard = getKingBitboard(bitboards: boardState.bitboards, color: .white)
    return (attackTable & kingBitboard) != 0
}

func isBlackKingChecked(boardState: BoardState) -> Bool {
    let attackTable = generateAllAttackedSquares(bitboards: boardState.bitboards, currentColor: .black)
    let kingBitboard = getKingBitboard(bitboards: boardState.bitboards, color: .black)
    return (attackTable & kingBitboard) != 0
}
//
//  KingMovesGenerator.swift
//  Chessblazer
//
//  Created by sergiusz on 10/10/2024.
//

import Foundation

func generateKingMovesBitboard(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move]) {
    let attackedSquares = generateAllAttackedSquares(bitboards: bitboards, currentColor: currentColor)
    var friendlyMask = Bitboard(0)
    var kingBitboard = Bitboard(0)
        
    var pieceValue = 0
    
    if currentColor == .white {
        kingBitboard = bitboards[Piece.ColoredPieces.whiteKing.rawValue]!
        pieceValue = Piece.ColoredPieces.whiteKing.rawValue
        friendlyMask = Magic.whitePiecesBitboards(bitboards: bitboards)
        
        
    } else {
        kingBitboard = bitboards[Piece.ColoredPieces.blackKing.rawValue]!
        pieceValue = Piece.ColoredPieces.blackKing.rawValue
        friendlyMask = Magic.blackPiecesBitboards(bitboards: bitboards)
    }
    
    while kingBitboard != 0 {
        let square = Bitboard.popLSB(&kingBitboard)
        let king = Bitboard(1) << Bitboard(square)
        var movesBitboard = generateKingAttacks(king: king) & ~friendlyMask & ~attackedSquares
        
        while movesBitboard != 0 {
            let targetSquare = Bitboard.popLSB(&movesBitboard)
            let move = Move(fromSquare: square, targetSquare: targetSquare, pieceValue: pieceValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards))
            moves.append(move)
        }
    }
    
}

func generateCastles(bitboards: [Int: Bitboard], currentColor: Piece.Color, moves: inout [Move], castlesAvailable: Set<Character>) {
    let attackedSquares = generateAllAttackedSquares(bitboards: bitboards, currentColor: currentColor)
    
    if currentColor == .white {
        let kingBitboard = bitboards[Piece.ColoredPieces.whiteKing.rawValue]!
        let friendlyMask = Magic.allPieces(bitboards: bitboards)


        let isUnderAttack = kingBitboard & attackedSquares != 0
        if !isUnderAttack {
            
            let rooksBitboard = bitboards[Piece.ColoredPieces.whiteRook.rawValue]!
            

            let piecesRank1 = friendlyMask & Bitboard.Masks.rank1
            let rooksKing = rooksBitboard | kingBitboard
            
            let rightRookToKing = Bitboard(144)
            let rightCorrectPositions = rooksKing & rightRookToKing == rightRookToKing
            let isRightPathClear = Bitboard(96) & piecesRank1 == 0
            let isRightPathNotUnderAttack = attackedSquares & Bitboard(96) == 0
            let isRightPossible = isRightPathClear && isRightPathNotUnderAttack && rightCorrectPositions

            
            let leftRookToKing = Bitboard(17)
            let leftCorrectPositions = rooksKing & leftRookToKing == leftRookToKing
            let isLeftPathClear = Bitboard(14) & piecesRank1 == 0
            let isLeftPathNotUnderAttack = attackedSquares & Bitboard(12) == 0
            let isLeftPossible = isLeftPathClear && isLeftPathNotUnderAttack && leftCorrectPositions
            
            
            if isRightPossible && castlesAvailable.contains("K") {
                let move = Move(fromSquare: 4, targetSquare: 7, kingValue: Piece.ColoredPieces.whiteKing.rawValue, rookValue: Piece.ColoredPieces.whiteRook.rawValue,kingDestination: 6, rookDestination: 5)
                moves.append(move)
            }
            
            if isLeftPossible && castlesAvailable.contains("Q") {
                moves.append(Move(fromSquare: 4, targetSquare: 0, kingValue: Piece.ColoredPieces.whiteKing.rawValue, rookValue: Piece.ColoredPieces.whiteRook.rawValue, kingDestination: 2, rookDestination: 3))
            }
        }
        
    } else {
        let kingBitboard = bitboards[Piece.ColoredPieces.blackKing.rawValue]!
        let friendlyMask = Magic.allPieces(bitboards: bitboards)
        let isUnderAttack = kingBitboard & attackedSquares != 0

        if !isUnderAttack {
            let rooksBitboard = bitboards[Piece.ColoredPieces.blackRook.rawValue]!
            let piecesRank8 = friendlyMask & Bitboard.Masks.rank8
            let rooksKing = rooksBitboard | kingBitboard
            
            let rightRookToKing = Bitboard(10376293541461622784)
            let rightCorrectPositions = rooksKing & rightRookToKing == rightRookToKing
            let isRightPathClear = Bitboard(6917529027641081856) & piecesRank8 == 0
            let isRightPathNotUnderAttack = attackedSquares & Bitboard(6917529027641081856) == 0
            let isRightPossible = isRightPathClear && isRightPathNotUnderAttack && rightCorrectPositions

            let leftRookToKing = Bitboard(1224979098644774912)
            let leftCorrectPositions = rooksKing & leftRookToKing == leftRookToKing
            let isLeftPathClear = Bitboard(1008806316530991104) & piecesRank8 == 0
            let isLeftPathNotUnderAttack = attackedSquares & Bitboard(864691128455135232) == 0
            let isLeftPossible = isLeftPathClear && isLeftPathNotUnderAttack && leftCorrectPositions
            
            if isRightPossible && castlesAvailable.contains("k") {
                moves.append(Move(fromSquare: 60, targetSquare: 63, kingValue: Piece.ColoredPieces.blackKing.rawValue, rookValue: Piece.ColoredPieces.blackRook.rawValue, kingDestination: 62, rookDestination: 61))
            }
            
            if isLeftPossible && castlesAvailable.contains("q") {
                moves.append(Move(fromSquare: 60, targetSquare: 56, kingValue: Piece.ColoredPieces.blackKing.rawValue, rookValue: Piece.ColoredPieces.blackRook.rawValue, kingDestination: 58, rookDestination: 59))
            }
        }
    }
}

func generateKingAttacks(king: Bitboard) -> Bitboard {
    var attacks = king.eastOne() | king.westOne()
    let kingSet = king | attacks
    attacks = attacks | (kingSet.northOne() | kingSet.southOne())
    return attacks
}
func generateKingAttacks(square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    
    var kingBitboard = Bitboard(1) << Bitboard(square)
    
    let square = Bitboard.popLSB(&kingBitboard)
    let king = Bitboard(1) << Bitboard(square)
    let movesBitboard = generateKingAttacks(king: king) & ~friendlyBitboard
    return movesBitboard
    
}
//
//  KnightMovesGenerator.swift
//  Chessblazer
//
//  Created by sergiusz on 10/10/2024.
//

import Foundation


func generateKnightMoves(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move]) {
    var friendlyMask = Bitboard(0)
    var knightBitboard = Bitboard(1) << Bitboard(square)
    var pieceValue = 0
    if currentColor == .white {
        friendlyMask = Magic.whitePiecesBitboards(bitboards: bitboards)
        pieceValue = Piece.ColoredPieces.whiteKnight.rawValue
    } else {
        friendlyMask = Magic.blackPiecesBitboards(bitboards: bitboards)
        pieceValue = Piece.ColoredPieces.blackKnight.rawValue

    }
    
    while knightBitboard != 0 {
        let square = Bitboard.popLSB(&knightBitboard)
        let knight = Bitboard(1) << Bitboard(square)
        var movesBitboard = generateKnightAttacks(bitboard: knight) & ~friendlyMask
        while movesBitboard != 0 {
            let targetSquare = Bitboard.popLSB(&movesBitboard)
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: pieceValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
        }
    }
}

func generateKnightAttacks(bitboard: UInt64) -> UInt64 {
    
    let firstHalf: UInt64 = ((bitboard << 15) | (bitboard >> 17)) & ~Bitboard.Masks.fileH |
    ((bitboard << 17) | (bitboard >> 15)) & ~Bitboard.Masks.fileA
    
    let secondHalf: UInt64 = ((bitboard << 6) | (bitboard >> 10)) & ~Bitboard.Masks.fileGH |
    ((bitboard << 10) | (bitboard >> 6)) & ~Bitboard.Masks.fileAB
    
    return firstHalf | secondHalf
}

func generateKnightAttacks(square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    var knightBitboard = Bitboard(1) << Bitboard(square)
    let square = Bitboard.popLSB(&knightBitboard)
    let knight = Bitboard(1) << Bitboard(square)
    let movesBitboard = generateKnightAttacks(bitboard: knight) & ~friendlyBitboard
    return movesBitboard
}
//
//  Move.swift
//  Chessblazer
//
//  Created by sergiusz on 26/07/2024.
//

import Foundation

class Move: Equatable, Hashable, Comparable, Codable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fromSquare!+targetSquare!+enPasssantCapture)
    }
    
    var castling = false
//    var castlingDestinations: (king: Int, rook: Int) = (0, 0)
    var castlingRookDestination = 0
    var castlingKingDestination = 0
    var fromSquare: Int?
    var targetSquare: Int?
    var promotionPiece: Int = 0
    var enPasssantCapture = 0
    
    var pieceValue: Int = 0
    var captureValue = 0

    var asString: String {
        "\(fromSquare!) \(targetSquare!)"
    }
    
    init(fromSquare: Int, targetSquare: Int, enPasssantCapture: Int, pieceValue: Int, captureValue: Int) {
        self.fromSquare = fromSquare
        self.targetSquare = targetSquare
        self.enPasssantCapture = enPasssantCapture
        self.pieceValue = pieceValue
        self.captureValue = captureValue
    }
    
    init(fromSquare: Int, targetSquare: Int, pieceValue: Int,  captureValue: Int) {
        self.fromSquare = fromSquare
        self.targetSquare = targetSquare
        self.captureValue = captureValue
        self.pieceValue = pieceValue
    }
    
    init(fromSquare: Int, targetSquare: Int, pieceValue: Int,  captureValue: Int, promotionPiece: Int) {
        self.fromSquare = fromSquare
        self.targetSquare = targetSquare
        self.captureValue = captureValue
        self.pieceValue = pieceValue
        self.promotionPiece = promotionPiece
    }
    
    init(fromSquare: Int, targetSquare: Int, kingValue: Int, rookValue: Int, kingDestination: Int, rookDestination: Int) {
        self.castling = true
        self.fromSquare = fromSquare
        self.targetSquare = targetSquare
        self.pieceValue = kingValue
        self.captureValue = rookValue
        self.castlingKingDestination = kingDestination
        self.castlingRookDestination = rookDestination
        
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return (lhs.fromSquare == rhs.fromSquare) && (lhs.targetSquare == rhs.targetSquare)
    }
#warning("think about it")
    func moveValue(attackPawnTable: Bitboard = Bitboard(0)) -> Int {
        var score = 0
        let pieceRealValue = PieceValueTable[pieceValue]!
        let captureRealValue = PieceValueTable[pieceValue]!

        if Piece.getType(piece: captureValue) == .king {
            score += 50
        } else if captureValue != 0 {
            score += abs(captureRealValue) * 10 - abs(pieceRealValue)
        }
        
        if promotionPiece != 0 {
            score += promotionPiece
        }

        let b = (Bitboard(1) << Bitboard(targetSquare!))
        if b & attackPawnTable == b {
            score -= abs(pieceRealValue)
        }
        return score
    }
    
    static func < (lhs: Move, rhs: Move) -> Bool {
        return lhs.moveValue() < rhs.moveValue()
    }
    init(notation: String) {
                
        if notation.count == 4 {
            self.fromSquare = translateFromNotationToSquare(String(notation.prefix(2)))
            self.targetSquare = translateFromNotationToSquare(String(notation.suffix(2)))
        } else {
            self.fromSquare = translateFromNotationToSquare(String(notation.prefix(2)))
            
            let start = notation.index(notation.startIndex, offsetBy: 2)
            let end = notation.index(notation.startIndex, offsetBy: 4)
            self.targetSquare = translateFromNotationToSquare(String(notation[start..<end]))
            if let pp = Piece.ColoredPiecesDict[String(notation.suffix(1))] {
                self.promotionPiece = pp.rawValue
            }
        }
        self.pieceValue = 0
    }
    
    func squareToNotation(square: Int) -> String {
        let ranks = square / 8 + 1
        let files = square % 8
        let letters = "abcdefgh"

        guard ranks >= 1 && ranks <= 8 && files >= 0 && files < 8 else {
            return "Invalid square"
        }

        let fileLetter = letters[letters.index(letters.startIndex, offsetBy: files)]
        return "\(fileLetter)\(ranks)"
    }
    
    func moveToNotation() -> String {
        return "\(squareToNotation(square: fromSquare!))\(squareToNotation(square: targetSquare!))"
    }
    
    var letterToNumber: [String : Int] = [
        "A" : 0,
        "B" : 1,
        "C" : 2,
        "D" : 3,
        "E" : 4,
        "F" : 5,
        "G" : 6,
        "H" : 7,
    ]
    
    func translateFromNotationToSquare(_ notation: String) -> Int? {
        guard notation.count == 2 else { return nil }
        let letter = String(notation.prefix(1))
        guard let fileIndex = letterToNumber[letter.uppercased()] else { return nil }
        guard let rankNumber: Int = Int(String(notation.suffix(1))), rankNumber >= 1, rankNumber <= 8 else { return nil }
        let rankIndex = rankNumber - 1
        return 8 * rankIndex + fileIndex
    }
}
//
//  PawnMovesGenerator.swift
//  Chessblazer
//
//  Created by sergiusz on 05/09/2024.
//

import Foundation

// Moves
func whitePawnOnePush(whitePawns: Bitboard, emptySquares: Bitboard) -> Bitboard {
    return (whitePawns << 8) & emptySquares
}

func whitePawnDoublePush(whitePawns: Bitboard, emptySquares: Bitboard) -> Bitboard {
    let singlePush = whitePawnOnePush(whitePawns: whitePawns, emptySquares: emptySquares)
    return (singlePush << 8) & emptySquares & Bitboard.Masks.rank4
}

func blackPawnOnePush(blackPawns: Bitboard, emptySquares: Bitboard) -> Bitboard{
    return (blackPawns >> 8) & emptySquares
}

func blackPawnDoublePush(blackPawns: Bitboard, emptySquares: Bitboard) -> Bitboard {
    let singlePush = blackPawnOnePush(blackPawns: blackPawns, emptySquares: emptySquares)
    return (singlePush >> 8) & emptySquares & Bitboard.Masks.rank5
}

// Attacks
func generateWhitePawnAttacks(whitePawns: Bitboard) -> Bitboard {
    let whitePawnAttacks = ((whitePawns << 9) & ~Bitboard.Masks.fileA) |
    ((whitePawns << 7) & ~Bitboard.Masks.fileH)
    return whitePawnAttacks
}

func generateBlackPawnAttacks(blackPawns: Bitboard) -> Bitboard {
    let blackPawnAttacks = ((blackPawns >> 7) & ~Bitboard.Masks.fileA) | ((blackPawns >> 9) & ~Bitboard.Masks.fileH)
    return blackPawnAttacks
}


func generateWhitePawnMoves(bitboards: [Int: Bitboard], square: Int, moves: inout [Move]) {
    let empty = emptySquaresBitboard(bitboards: bitboards)
    
    let pawn = Bitboard(1) << Bitboard(square)
    var movesBitboard = whitePawnOnePush(whitePawns: pawn, emptySquares: empty) | whitePawnDoublePush(whitePawns: pawn, emptySquares: empty) | (generateWhitePawnAttacks(whitePawns: pawn) & Magic.blackPiecesBitboards(bitboards: bitboards))
    
    
    
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        
        if pawn & Bitboard.Masks.rank7 == pawn {
            for piece in Piece.ColoredPieces.possibleWhitePromotions() {
                moves.append(
                    Move(
                        fromSquare: square,
                        targetSquare: targetSquare,
                        pieceValue: Piece.ColoredPieces.whitePawn.rawValue,
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.whitePawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
        }
    }
}

func generateWhitePawnAttacks(bitboards: [Int: Bitboard], square: Int, moves: inout [Move]) {
    let pawn = Bitboard(1) << Bitboard(square)
    var movesBitboard = generateWhitePawnAttacks(whitePawns: pawn)
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        
        if pawn & Bitboard.Masks.rank7 == pawn {
            for piece in Piece.ColoredPieces.possibleWhitePromotions() {
                moves.append(
                    Move(
                        fromSquare: square,
                        targetSquare: targetSquare,
                        pieceValue: Piece.ColoredPieces.whitePawn.rawValue,
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.whitePawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
        }
        
        
    }
}

func generateWhitePawnAttacks(square: Int) -> Bitboard {
    let pawn = UInt64(1) << square
    return generateWhitePawnAttacks(whitePawns: pawn)
}

func generateBlackPawnAttacks(bitboards: [Int: Bitboard], square: Int, moves: inout [Move]) {
    let pawn = Bitboard(1 << square)
    var movesBitboard = generateBlackPawnAttacks(blackPawns: pawn)
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        
        if pawn & Bitboard.Masks.rank2 == pawn {
            for piece in Piece.ColoredPieces.possibleBlackPromotions() {
                moves.append(
                    Move(
                        fromSquare: square,
                        targetSquare: targetSquare,
                        pieceValue: Piece.ColoredPieces.blackPawn.rawValue,
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.blackPawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
        }
        
        
        
    }
}

func generateBlackPawnAttacks(square: Int) -> Bitboard {
    let pawn = Bitboard(1 << square)
    return generateBlackPawnAttacks(blackPawns: pawn)
    
}



func generateBlackPawnMoves(bitboards: [Int: Bitboard], square: Int, moves: inout [Move]) {
    
    let empty = emptySquaresBitboard(bitboards: bitboards)
    
    let pawn = Bitboard(1 << square)
    var movesBitboard = blackPawnOnePush(blackPawns: pawn, emptySquares: empty) | blackPawnDoublePush(blackPawns: pawn, emptySquares: empty) | (generateBlackPawnAttacks(blackPawns: pawn) & Magic.whitePiecesBitboards(bitboards: bitboards))
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        
        if pawn & Bitboard.Masks.rank2 == pawn {
            for piece in Piece.ColoredPieces.possibleBlackPromotions() {
                moves.append(
                    Move(
                        fromSquare: square,
                        targetSquare: targetSquare,
                        pieceValue: Piece.ColoredPieces.blackPawn.rawValue,
                        captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards),
                        promotionPiece: piece.rawValue
                    ))
            }
        } else {
            moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: Piece.ColoredPieces.blackPawn.rawValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
        }
        
    }
}

func generatePawnMoves(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move]) {
    
    if currentColor == .white {
        generateWhitePawnMoves(bitboards: bitboards, square: square, moves: &moves)
    } else {
        generateBlackPawnMoves(bitboards: bitboards, square: square, moves: &moves)
    }
}
func generatePawnAttacks(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move]) {
    
    if currentColor.getOppositeColor() == .white {
        generateWhitePawnAttacks(bitboards: bitboards, square: square, moves: &moves)
    } else {
        generateBlackPawnAttacks(bitboards: bitboards, square: square, moves: &moves)
    }
}

func generatePawnAttacks(currentColor: Piece.Color, square: Int) -> Bitboard {
    
    if currentColor == .white {
        return generateWhitePawnAttacks(square: square)
    } else {
        return generateBlackPawnAttacks(square: square)
        
    }
}


func enPassantCheck(bitboards: [Int: Bitboard], lastMove: Move) -> [Move] {
    var moves = Set<Move>()
    guard let from = lastMove.fromSquare, let target = lastMove.targetSquare else { return [Move]() }
    
    if lastMove.pieceValue == Piece.ColoredPieces.whitePawn.rawValue {
        if (8...15).contains(from) && (24...31).contains(target) {
            var blackPawns = bitboards[Piece.ColoredPieces.blackPawn.rawValue]! & Bitboard.Masks.rank4
            while (blackPawns != 0) {
                let blackPawn = Bitboard.popLSB(&blackPawns)
                if blackPawn-1 == target || blackPawn+1 == target {
                    moves.insert(Move(fromSquare: blackPawn, targetSquare: target - 8, enPasssantCapture: target, pieceValue: Piece.ColoredPieces.blackPawn.rawValue, captureValue: Piece.ColoredPieces.whitePawn.rawValue))
                }
            }
        }
    } else if lastMove.pieceValue == Piece.ColoredPieces.blackPawn.rawValue {
        if (48...55).contains(from) && (32...39).contains(target) {
            var whitePawns = bitboards[Piece.ColoredPieces.whitePawn.rawValue]! & Bitboard.Masks.rank5
            while (whitePawns != 0) {
                let whitePawn = Bitboard.popLSB(&whitePawns)
                if whitePawn-1 == target || whitePawn+1 == target {
                    moves.insert(Move(fromSquare: whitePawn, targetSquare: target+8, enPasssantCapture: target, pieceValue: Piece.ColoredPieces.whitePawn.rawValue, captureValue: Piece.ColoredPieces.blackPawn.rawValue))
                }
            }
            
        }
    }
//    if !moves.isEmpty {
//        let movesSet = Set(moves)
//        
//        for m in movesSet {
//            print(m.moveToNotation())
//        }
//    }
    return Array(moves)
}
//
//  SliderMovesGenerator.swift
//  Chessblazer
//
//  Created by sergiusz on 10/10/2024.
//

import Foundation
func generateRookMoves(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move]) {
    let whitePieces = Magic.whitePiecesBitboards(bitboards: bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: bitboards)
    let allPieces = whitePieces | blackPieces
    let blockerBitboard = allPieces & Rook.masks[square] // & checkRayMask
    var movesBitboard = Rook.lookUpTable[square]![magicIndex(magic: rookMagics[square], shift: rookShifts[square], blocker: blockerBitboard)]!
    var pieceValue = 0
    
    if currentColor == .white {
        movesBitboard = movesBitboard & ~whitePieces
        pieceValue = Piece.ColoredPieces.whiteRook.rawValue
    } else {
        movesBitboard = movesBitboard & ~blackPieces
        pieceValue = Piece.ColoredPieces.blackRook.rawValue

    }
    while movesBitboard != 0 {
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: pieceValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
    }
}
func generateRookAttacks(bitboards: [Int: Bitboard], square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    let whitePieces = Magic.whitePiecesBitboards(bitboards: bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: bitboards)
    let allPieces = whitePieces | blackPieces
    let blockerBitboard = allPieces & Rook.masks[square] // & checkRayMask
    var movesBitboard = Rook.lookUpTable[square]![magicIndex(magic: rookMagics[square], shift: rookShifts[square], blocker: blockerBitboard)]!
    movesBitboard = movesBitboard & ~friendlyBitboard
    return movesBitboard
}

func generateBishopMoves(bitboards: [Int: Bitboard], currentColor: Piece.Color,square: Int, moves: inout [Move]) {
    
    let whitePieces = Magic.whitePiecesBitboards(bitboards: bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: bitboards)
    let allPieces = whitePieces | blackPieces
    
    let blockerBitboard = allPieces & Bishop.masks[square] // & checkRayMask
    
    var movesBitboard = Bishop.lookUpTable[square]![magicIndex(magic: bishopMagics[square], shift: bishopShifts[square], blocker: blockerBitboard)]!
    
    var pieceValue = 0
    if currentColor == .white {
        movesBitboard = movesBitboard & ~whitePieces
        pieceValue = Piece.ColoredPieces.whiteBishop.rawValue
    } else {
        movesBitboard = movesBitboard & ~blackPieces
        pieceValue = Piece.ColoredPieces.blackBishop.rawValue

    }
    
    while movesBitboard != 0 {
        
        let targetSquare: Int = Bitboard.popLSB(&movesBitboard)
        moves.append(Move(fromSquare: square, targetSquare: targetSquare, pieceValue: pieceValue, captureValue: getPieceValueFromField(at: targetSquare, bitboards: bitboards)))
    }
}


func generateBishopAttacks(bitboards: [Int: Bitboard], square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    let whitePieces = Magic.whitePiecesBitboards(bitboards: bitboards)
    let blackPieces = Magic.blackPiecesBitboards(bitboards: bitboards)
    let allPieces = whitePieces | blackPieces
    let blockerBitboard = allPieces & Bishop.masks[square]
    var movesBitboard = Bishop.lookUpTable[square]![magicIndex(magic: bishopMagics[square], shift: bishopShifts[square], blocker: blockerBitboard)]!
    movesBitboard = movesBitboard & ~friendlyBitboard
    return movesBitboard
}

func generateQueenMoves(bitboards: [Int: Bitboard], currentColor: Piece.Color, square: Int, moves: inout [Move]) {
    var queenMoves = [Move]()
    let queen: Piece.ColoredPieces = currentColor == .white ? .whiteQueen : .blackQueen
    generateRookMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &queenMoves)
    generateBishopMoves(bitboards: bitboards, currentColor: currentColor, square: square, moves: &queenMoves)
    queenMoves = queenMoves.map { move in
        move.pieceValue = queen.rawValue
        return move
    }
    moves.append(contentsOf: queenMoves)
}

func generateQueenAttacks(bitboards: [Int: Bitboard], square: Int, friendlyBitboard: Bitboard) -> Bitboard {
    return generateBishopAttacks(bitboards: bitboards, square: square, friendlyBitboard: friendlyBitboard) | generateRookAttacks(bitboards: bitboards, square: square, friendlyBitboard: friendlyBitboard)
}
//
//  Untitled.swift
//  Chessblazer
//
//  Created by sergiusz on 10/10/2024.
//

//
//  Perf.swift
//  Chessblazer
//
//  Created by sergiusz on 05/09/2024.
//

import Foundation

// bulk

func perftTest(depth: Int) -> (Int, PerftData) {
    let game = Game()
    var perftData = PerftData()    
    func perft(depth: Int, game: Game) -> Int {
        var nodeCount = 0
        
        if depth == 1 {
            
            for move in game.boardState.currentValidMoves {

                
                game.makeMove(move: move)
                
                if game.boardState.currentValidMoves.isEmpty && checkIfCheck(boardState: game.boardState) {
                    perftData.checkmates += 1
                }
                
                if checkIfCheck(boardState: game.boardState) {
                    perftData.checks += 1
                }
                
                if move.captureValue != 0 && !move.castling {
                    perftData.captures += 1
                }
                if move.enPasssantCapture != 0 {
                    perftData.enPassants += 1
                }
                if move.castling {

                    perftData.castles += 1

                    
                }
                game.undoMove()
            }
            
            return game.boardState.currentValidMoves.count
        }
        
        if game.boardData.hasGameEnded {
            return 0
        }
        
        for move in game.boardState.currentValidMoves {
            game.makeMove(move: move)
            
            nodeCount += perft(depth: depth - 1, game: game)
            game.undoMove()
        }
        return nodeCount
    }
    return (perft(depth: depth, game: game), perftData)
}

func perftTest(depth: Int, fen: String) -> (Int, PerftData) {
    var perftData = PerftData()
    let game = Game()
    game.loadFromFen(fen: fen)
    func perft(depth: Int, game: Game) -> Int {
        var nodeCount = 0
        
        if depth == 1 {
            
            if game.boardData.hasGameEnded {
                return 0
            }
            let moves = game.boardState.currentValidMoves

                for move in moves {
                    game.makeMove(move: move)

                    if move.castling {
                        perftData.castles += 1

                    }
                    
                    if game.boardState.currentValidMoves.isEmpty && checkIfCheck(boardState: game.boardState) {
                        perftData.checkmates += 1
                    }
                    
                    if checkIfCheck(boardState: game.boardState) {
                        perftData.checks += 1
                    }
                    
                    if move.promotionPiece != 0 {
                        perftData.promotions += 1
                    }
                    
                    
                    if move.captureValue != 0 && !move.castling {
                        perftData.captures += 1
                    }
                    if move.enPasssantCapture != 0 {
                        perftData.enPassants += 1
                    }
                    game.undoMove()
                }
                return moves.count
        }
        for move in game.boardState.currentValidMoves {
            game.makeMove(move: move)
            
            nodeCount += perft(depth: depth - 1, game: game)
            game.undoMove()
        }
        return nodeCount
    }
    
    return (perft(depth: depth, game: game), perftData)
}

func bulkPerftTest(depth: Int) -> Int {
    bulkPerftTest(depth: depth, fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
}

func bulkPerftTest(depth: Int, fen: String) -> Int {
    let game = Game()
    game.loadFromFen(fen: fen)
    func perft(depth: Int, game: Game) -> Int {
        var nodeCount = 0
        
        if depth == 1 {
            return game.boardState.currentValidMoves.count
        }
        
        if game.boardData.hasGameEnded {
            return 0
        }
        
        for move in game.boardState.currentValidMoves {
            game.makeMove(move: move)
            nodeCount += perft(depth: depth - 1, game: game)
            game.undoMove()
        }
        return nodeCount
    }
    return perft(depth: depth, game: game)
}
//
//  Pieces.swift
//  Chessblazer
//
//  Created by sergiusz on 25/07/2024.
//

import Foundation

class Piece {
    enum PieceType: Int {
        case empty = 0
        case king = 1
        case pawn = 2
        case knight = 3
        case bishop = 4
        case rook = 5
        case queen = 6
    }
    
    
    enum Color: Int {
        case white = 8
        case black = 16
        case none = 0
        func getOppositeColor() -> Color {
            if self == .white {
                return .black
            } else {
                return .white
            }
        }
        mutating func toggleColor() {
            if self == .white {
                self = .black
            } else {
                self = .white
            }
        }
    }
    
    enum ColoredPieces: Int, CaseIterable {
        
        case empty = 0
        case blackKing = 17
        case blackPawn = 18
        case blackQueen = 22
        case blackKnight = 19
        case blackBishop = 20
        case blackRook = 21
    
        case whiteKing = 9
        case whitePawn = 10
        case whiteQueen = 14
        case whiteKnight = 11
        case whiteBishop = 12
        case whiteRook = 13
        
        static func possibleWhitePromotions() -> [ColoredPieces] {
            return [.whiteQueen, .whiteRook, .whiteKnight, .whiteBishop]
        }
        
        static func possibleBlackPromotions() -> [ColoredPieces] {
            return [.blackQueen, .blackRook, .blackKnight, .blackBishop]
        }
        
    }
    
    static func combine(type: PieceType, color: Color) -> Int {
        return type.rawValue | color.rawValue
    }
    
    static func isType(piece: Int, typeToCheck: PieceType) -> Bool {
        return piece == combine(type: typeToCheck, color: .black) || piece == combine(type: typeToCheck, color: .white)
        
    }
    
    static func getType(piece: Int) -> PieceType {
        let colorValue = checkColor(piece: piece) == .white ? Color.white.rawValue : Color.black.rawValue
        let noColorPiece = piece - colorValue
        return PieceType(rawValue: noColorPiece) ?? PieceType.empty
        
    }
    
    
    static func checkColor(piece: Int) -> Piece.Color {
        if piece / Piece.Color.black.rawValue == 1 {
            return .black
        } else {
            return .white
        }
    }
    
    static func areOppositeColors(piece1: Int, piece2: Int) -> Bool {
        return Piece.checkColor(piece: piece1) != Piece.checkColor(piece: piece2)
        
    }
    

    static func isSliding(piece: Int) -> Bool {
        return Piece.isType(piece: piece, typeToCheck: .bishop) || Piece.isType(piece: piece, typeToCheck: .queen) || Piece.isType(piece: piece, typeToCheck: .rook)
    }
    
    static func isLeaping(piece: Int) -> Bool {
        return Piece.isType(piece: piece, typeToCheck: .pawn) || Piece.isType(piece: piece, typeToCheck: .knight) || Piece.isType(piece: piece, typeToCheck: .king)
    }
    
    
    static let PiecesDict: [Character: PieceType] = [
        "0": PieceType.empty,
        "k": PieceType.king,
        "p": PieceType.pawn,
        "n": PieceType.knight,
        "b": PieceType.bishop,
        "r": PieceType.rook,
        "q": PieceType.queen
    ]
    
    static let ColoredPiecesDict: [String: ColoredPieces] = [
        "k": ColoredPieces.blackKing,
        "p": ColoredPieces.blackPawn,
        "n": ColoredPieces.blackKnight,
        "b": ColoredPieces.blackBishop,
        "r": ColoredPieces.blackRook,
        "q": ColoredPieces.blackQueen,
        
        "K": ColoredPieces.whiteKing,
        "P": ColoredPieces.whitePawn,
        "N": ColoredPieces.whiteKnight,
        "B": ColoredPieces.whiteBishop,
        "R": ColoredPieces.whiteRook,
        "Q": ColoredPieces.whiteQueen
        
    ]
    
    static let ValueToPieceDict: [Int: Character] = [
        0: ".",
        combine(type: .king, color: .black): "k",
        combine(type: .pawn, color: .black): "p",
        combine(type: .knight, color: .black): "n",
        combine(type: .bishop, color: .black): "b",
        combine(type: .rook, color: .black): "r",
        combine(type: .queen, color: .black): "q",
        combine(type: .king, color: .white): "K",
        combine(type: .pawn, color: .white): "P",
        combine(type: .knight, color: .white): "N",
        combine(type: .bishop, color: .white): "B",
        combine(type: .rook, color: .white): "R",
        combine(type: .queen, color: .white): "Q"
    ]
    
    // ♚ ♛ ♝ ♞ ♟ ♜
    // ♔ ♕ ♗ ♘ ♙ ♖
    
    static let ValueToPieceEmojiDict: [Int: Character] = [
        0: ".",
        combine(type: .king, color: .black): "♚",
        combine(type: .pawn, color: .black): "♟",
        combine(type: .knight, color: .black): "♞",
        combine(type: .bishop, color: .black): "♝",
        combine(type: .rook, color: .black): "♜",
        combine(type: .queen, color: .black): "♛",
        combine(type: .king, color: .white): "♔",
        combine(type: .pawn, color: .white): "♙",
        combine(type: .knight, color: .white): "♘",
        combine(type: .bishop, color: .white): "♗",
        combine(type: .rook, color: .white): "♖",
        combine(type: .queen, color: .white): "♕"
    ]
}

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
#warning("to handle")

//            result.searchMoves = match.1.split(separator: " ").map {
//                Move(notation: String($0))
//            }
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
