//
//  MahjongSetTests.swift
//  
//
//  Created by Rex Ma on 4/7/24.
//

import XCTest
@testable import MahjongCore

final class MahjongSetTests: XCTestCase {
    var set: [MahjongSet] = []
    override func setUpWithError() throws {
        Task {
            await ModelLoader.loadObjects()
            print("complete loading")
            await set.append(MahjongSet())
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func testMahjongSet() throws {
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
