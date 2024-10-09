//
//  ChessblazerEngineTests.swift
//  ChessblazerEngineTests
//
//  Created by sergiusz on 06/08/2024.
//

import XCTest

final class ChessblazerEngineTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerftTime() {
        measure {
            assert(perftTest(depth: 0) == 1)
            assert(perftTest(depth: 1) == 20)
            assert(perftTest(depth: 2) == 400)
            assert(perftTest(depth: 3) == 8902)
            assert(perftTest(depth: 4) == 197281)
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            
        }
    }

}
