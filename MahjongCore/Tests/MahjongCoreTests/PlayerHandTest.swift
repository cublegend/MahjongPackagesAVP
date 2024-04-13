//
//  PlayerTests.swift
//  MahjongDemoTests
//
//  Created by Katherine Xiong on 3/31/24.
//

import XCTest
import RealityKit
import MahjongCommons
@testable import MahjongCore

class MockStyle: IMahjongStyle {
    var name: String = ""
    
    func findBestFanGroup(closeHand: [any MahjongCommons.IMahjongFace], openHand: [any MahjongCommons.IMahjongFace]) -> [MahjongCommons.Fan] {
        return []
    }
    
    func calculateShanten(closeHand: [any MahjongCommons.IMahjongFace], completeSets: Int) -> Int {
        return 0
    }
    
    
}

final class PlayerHandTest: XCTestCase {
    var player: Player!
    var mahjongSet: MahjongSet!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        Task {
            await ModelLoader.loadObjects()
            mahjongSet = MahjongSet()
            mahjongSet.discardPile["Test"] = []
            let discardPile = mahjongSet.discardPile["Test"]
            let table = await TableEntity()
            player = Player(playerId: "Test", seat: getPlayerSeat(withIndex: 0), table: table, mahjongSet: mahjongSet, discardPile: discardPile!, style: MockStyle())
        }
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }
    
//    func testHandLogic() {
//        var array = [MahjongEntity]()
//        for _ in 0..<4 {
//            let tong1 = MahjongEntity(fileName: "Tong_1", renderContentToClone: <#T##ModelEntity#>, shapes: <#T##[ShapeResource]#>)
//            array.append()
//        }
//        player.addTilesToOpenHand(mahjongs: array)
//        XCTAssert(player.openHandCompleteSets)
//    }
    
}
