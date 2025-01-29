//
//  Perft_Initial_Position.swift
//  ChessblazerEngineTests
//
//  Created by sergiusz on 28/01/2025.
//

// based on
// https://www.chessprogramming.org/Perft_Results

/*
    use bulkPerftTest for expected nodes < 1 000 000
    use perftTest for detailed tests
 
 
 */

import Testing

@Suite("Perft tests")
struct Perft_Initial_Position {
    
    @Test(arguments: [
        (depth: 1, expectedNodes: 20),
        (depth: 2, expectedNodes: 400),
        (depth: 3, expectedNodes: 8902),
        (depth: 4, expectedNodes: 197281),
        (depth: 5, expectedNodes: 4865609),
    ])
    func testNodes(depth: Int, expectedNodes: Int) async throws {
        let timer = ContinuousClock().now
        let result = bulkPerftTest(depth: depth)
        let elapsedTime = timer.duration(to: .now)
        #expect(result == expectedNodes)
        print("Depth \(depth)" + ": \(elapsedTime) seconds")
        
    }

    @Test(arguments: [
        (depth: 1, expectedNodes: 20, expectedData: PerftData(captures: 0, enPassants: 0, castles: 0, checks: 0, checkmates: 0, promotions: 0)),
        (depth: 2, expectedNodes: 400, expectedData: PerftData(captures: 0, enPassants: 0, castles: 0, checks: 0, checkmates: 0, promotions: 0)),
        (depth: 3, expectedNodes: 8902, expectedData: PerftData(captures: 34, enPassants: 0, castles: 0, checks: 12, checkmates: 0, promotions: 0)),
        (depth: 4, expectedNodes: 197281, expectedData: PerftData(captures: 1576, enPassants: 0, castles: 0, checks: 469, checkmates: 8, promotions: 0)),
    ])
    func testDetails(depth: Int, expectedNodes: Int, expectedData: PerftData) async throws {
        let timer = ContinuousClock().now
        let result = perftTest(depth: depth)
        let elapsedTime = timer.duration(to: .now)
        #expect(result.0 == expectedNodes && result.1 == expectedData)
        print("Depth \(depth)" + ": \(elapsedTime) seconds")
    }
}
