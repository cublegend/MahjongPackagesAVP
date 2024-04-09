//
//  FanTests.swift
//
//  Created by Rex Ma on 4/2/24.
//

import XCTest
import MahjongCommons
@testable import MahjongAnalyzer

// mock mahjong class
class MockMahjong: IMahjongFace {
    var mahjongType: MahjongType
    
    var num: Int
    
    init(mahjongType: MahjongType, num: Int) {
        self.mahjongType = mahjongType
        self.num = num
    }
    
    func sameAs(_ mahjong: IMahjongFace?) ->Bool {
        guard let m = mahjong else { return false }
        return m.num == num && m.mahjongType == mahjongType
    }
}

class TestHand {
    static func constructHand(_ str: String)->[MockMahjong] {
        var tiles:[MockMahjong] = []
        var tmp:[MockMahjong] = []
        let chars = Array(str)
        for i in 0..<chars.count {
            var type = MahjongType.Wan
            var isNumber = false
            switch(chars[i]) {
                case "m": type = MahjongType.Wan
                case "p": type = MahjongType.Tong
                case "s": type = MahjongType.Tiao
                default: isNumber = true
            }
            if isNumber {
                tmp.append(MockMahjong(mahjongType: .Tiao, num: chars[i].wholeNumberValue!))
            } else {
                tmp.forEach({$0.mahjongType = type})
                tiles.append(contentsOf: tmp)
                tmp.removeAll()
            }
        }
        return tiles
    }
    
    static func printHand(_ hand: [IMahjongFace]) {
        var str = ""
        hand.forEach({str+="\(String($0.num))\($0.mahjongType.text) "})
        print(str)
    }
}

final class FanTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPongPong() throws {
        var closeHand = TestHand.constructHand("111p222333444s55m")
        XCTAssertTrue(BloodyAnalyzer.isPongPong(closeHand: closeHand))
        
        closeHand = TestHand.constructHand("333444s55m")
        XCTAssertTrue(BloodyAnalyzer.isPongPong(closeHand: closeHand))
        
        closeHand = TestHand.constructHand("11122255588899m")
        XCTAssertTrue(BloodyAnalyzer.isPongPong(closeHand: closeHand))
        
        closeHand = TestHand.constructHand("33388m555s999p")
        XCTAssertTrue(BloodyAnalyzer.isPongPong(closeHand: closeHand))
        
        closeHand = TestHand.constructHand("22p")
        XCTAssertTrue(BloodyAnalyzer.isPongPong(closeHand: closeHand))
        
        closeHand = TestHand.constructHand("111s22p")
        XCTAssertTrue(BloodyAnalyzer.isPongPong(closeHand: closeHand))
        
        closeHand = TestHand.constructHand("123888999s22p")
        XCTAssertFalse(BloodyAnalyzer.isPongPong(closeHand: closeHand))
        
        closeHand = TestHand.constructHand("11224455s22p8899m")
        XCTAssertFalse(BloodyAnalyzer.isPongPong(closeHand: closeHand))
        
        closeHand = TestHand.constructHand("11112222333355s")
        XCTAssertFalse(BloodyAnalyzer.isPongPong(closeHand: closeHand))
        
        closeHand = TestHand.constructHand("778899m11p")
        XCTAssertFalse(BloodyAnalyzer.isPongPong(closeHand: closeHand))
    }

    func testQingYiSe() throws {
        var hand = TestHand.constructHand("11123345678999m")
        XCTAssertTrue(BloodyAnalyzer.isQingYiSe(fullHand: hand))
        
        hand = TestHand.constructHand("11223344668899s")
        XCTAssertTrue(BloodyAnalyzer.isQingYiSe(fullHand: hand))
        
        hand = TestHand.constructHand("11223344668899p")
        XCTAssertTrue(BloodyAnalyzer.isQingYiSe(fullHand: hand))
        // kang
        hand = TestHand.constructHand("11113333555599s")
        XCTAssertTrue(BloodyAnalyzer.isQingYiSe(fullHand: hand))
        
        hand = TestHand.constructHand("112233446688s99p")
        XCTAssertFalse(BloodyAnalyzer.isQingYiSe(fullHand: hand))
        
        hand = TestHand.constructHand("11p2233446688s99m")
        XCTAssertFalse(BloodyAnalyzer.isQingYiSe(fullHand: hand))
        
        hand = TestHand.constructHand("111133335555m99s")
        XCTAssertFalse(BloodyAnalyzer.isQingYiSe(fullHand: hand))
        
    }

    func testCountGen() throws {
        var hand = TestHand.constructHand("111222333m444p88s")
        XCTAssertTrue(BloodyAnalyzer.countGen(fullHand: hand) == 0)
        
        hand = TestHand.constructHand("1111222333m444p88s")
        XCTAssertTrue(BloodyAnalyzer.countGen(fullHand: hand) == 1)
        
        hand = TestHand.constructHand("11112222333m444p88s")
        XCTAssertTrue(BloodyAnalyzer.countGen(fullHand: hand) == 2)
        
        hand = TestHand.constructHand("11122223334m456p")
        XCTAssertTrue(BloodyAnalyzer.countGen(fullHand: hand) == 1)
        
        hand = TestHand.constructHand("11112333345666p")
        XCTAssertTrue(BloodyAnalyzer.countGen(fullHand: hand) == 2)
        
        hand = TestHand.constructHand("11114444668888m")
        XCTAssertTrue(BloodyAnalyzer.countGen(fullHand: hand) == 3)
        
    }

    func testYaoJiu() throws {
        var closeHand = TestHand.constructHand("123789m123s99p")
        var openHand = TestHand.constructHand("999s")
        XCTAssertTrue(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("789m123s99p")
        openHand = TestHand.constructHand("111999s")
        XCTAssertTrue(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("123s99p")
        openHand = TestHand.constructHand("999111s111p")
        XCTAssertTrue(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("11122233378999p")
        openHand = []
        XCTAssertTrue(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("111999m99p")
        openHand = TestHand.constructHand("999111s")
        XCTAssertTrue(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("11223377889999m")
        openHand = []
        XCTAssertTrue(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("112233s77889999m")
        openHand = []
        XCTAssertTrue(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("99s")
        openHand = TestHand.constructHand("111999m111999p")
        XCTAssertTrue(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("112233s789999m")
        openHand = TestHand.constructHand("777p")
        XCTAssertFalse(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("123s99m")
        openHand = TestHand.constructHand("777888999p") // this is ponged, so they can't form sequences anymore
        XCTAssertFalse(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("123s123p12388m")
        openHand = TestHand.constructHand("999p")
        XCTAssertFalse(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("112233s44499m")
        openHand = TestHand.constructHand("111p")
        XCTAssertFalse(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("111222m999s12399p")
        openHand = []
        XCTAssertFalse(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("111222m555s12399p")
        openHand = []
        XCTAssertFalse(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("99s")
        openHand = TestHand.constructHand("111222333m999p")
        XCTAssertFalse(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
        
        closeHand = TestHand.constructHand("99s")
        openHand = TestHand.constructHand("111333m555999p")
        XCTAssertFalse(BloodyAnalyzer.isYaoJiu(closeHand: closeHand, openHand: openHand))
    }

    func testQiXiaoDui() throws {
        var closeHand = TestHand.constructHand("11223344556699s")
        XCTAssertTrue(BloodyAnalyzer.isQiDuiZi(closeHand: closeHand))
        closeHand = TestHand.constructHand("1122m3344p556699s")
        XCTAssertTrue(BloodyAnalyzer.isQiDuiZi(closeHand: closeHand))
        closeHand = TestHand.constructHand("112299m44556699s")
        XCTAssertTrue(BloodyAnalyzer.isQiDuiZi(closeHand: closeHand))
        closeHand = TestHand.constructHand("11223344556666s") // qing long qi dui 1gen
        XCTAssertTrue(BloodyAnalyzer.isQiDuiZi(closeHand: closeHand))
        closeHand = TestHand.constructHand("111122226666m99s") // long qi dui 3gen
        XCTAssertTrue(BloodyAnalyzer.isQiDuiZi(closeHand: closeHand))
        closeHand = TestHand.constructHand("112233445566s")
        XCTAssertFalse(BloodyAnalyzer.isQiDuiZi(closeHand: closeHand))
        closeHand = TestHand.constructHand("112233s")
        XCTAssertFalse(BloodyAnalyzer.isQiDuiZi(closeHand: closeHand))
        closeHand = TestHand.constructHand("11223344445699s")
        XCTAssertFalse(BloodyAnalyzer.isQiDuiZi(closeHand: closeHand))
        closeHand = TestHand.constructHand("123456m123456s99p")
        XCTAssertFalse(BloodyAnalyzer.isQiDuiZi(closeHand: closeHand))
    }

    func testShiBaLuoHan() throws {
        var openHand = TestHand.constructHand("1111p2222s33338888m")
        XCTAssertTrue(BloodyAnalyzer.isShiBaLuoHan(openHand: openHand))
        openHand = TestHand.constructHand("1111333355559999m")
        XCTAssertTrue(BloodyAnalyzer.isShiBaLuoHan(openHand: openHand))
        openHand = TestHand.constructHand("1111p2222s3333m")
        XCTAssertFalse(BloodyAnalyzer.isShiBaLuoHan(openHand: openHand))
        openHand = TestHand.constructHand("111p222s333444m")
        XCTAssertFalse(BloodyAnalyzer.isShiBaLuoHan(openHand: openHand))
        openHand = TestHand.constructHand("1111p222s3333m")
        XCTAssertFalse(BloodyAnalyzer.isShiBaLuoHan(openHand: openHand))
        openHand = TestHand.constructHand("1111p2222s3338888m")
        XCTAssertFalse(BloodyAnalyzer.isShiBaLuoHan(openHand: openHand))
    }

    func testJinGou() throws {
        var closeHand = TestHand.constructHand("88m")
        XCTAssertTrue(BloodyAnalyzer.isJinGou(closeHandCount: closeHand.count))
        closeHand = TestHand.constructHand("11188m")
        XCTAssertFalse(BloodyAnalyzer.isJinGou(closeHandCount: closeHand.count))
        closeHand = TestHand.constructHand("11122255588m")
        XCTAssertFalse(BloodyAnalyzer.isJinGou(closeHandCount: closeHand.count))
    }

    func testfindBestFanGroupBloody() throws {
        // qing qi dui
        var closeHand = TestHand.constructHand("11224455668899p")
        var openHand:[MockMahjong] = []
        var result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QingQiDui]))
        
        // long qi qidui
        closeHand = TestHand.constructHand("1122p4455668888m")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.LongQiDui]))
        
        // long qidui + 2 gen
        closeHand = TestHand.constructHand("1111p4444668888m")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.LongQiDui, .Gen, .Gen]))
        
        // qing long + 2 gen
        closeHand = TestHand.constructHand("11114444668888m")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QingLong, .Gen, .Gen]))
        
        // shibaluohan
        closeHand = TestHand.constructHand("33p")
        openHand = TestHand.constructHand("1111p4444s88889999m")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.ShiBaLuoHan]))
        
        // qingshibaluohan
        closeHand = TestHand.constructHand("33m")
        openHand = TestHand.constructHand("1111444488889999m")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QingShiBa]))
        
        // jingou + 3 gen, almost shibaluohan
        closeHand = TestHand.constructHand("33p")
        openHand = TestHand.constructHand("111144488889999m")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.JinGou, .Gen, .Gen, .Gen]))
        
        // qingjingou + 3 gen, almost qingshibaluohan
        closeHand = TestHand.constructHand("33m")
        openHand = TestHand.constructHand("111144488889999m")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QingJinGou, .Gen, .Gen, .Gen]))
        
        // qingjingou
        closeHand = TestHand.constructHand("33m")
        openHand = TestHand.constructHand("111444888999m")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QingJinGou]))
        
        // qingyaojiu + 2 gen
        closeHand = TestHand.constructHand("11112377889999m")
        openHand = []
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QingYaoJiu, .Gen, .Gen]))
        
        // qing pong
        closeHand = TestHand.constructHand("66699p")
        openHand = TestHand.constructHand("111333555p")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QingPong]))
        
        // qidui
        closeHand = TestHand.constructHand("1133p5566s118899m")
        openHand = []
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QiDuiZi]))
        
        // qingyise
        closeHand = TestHand.constructHand("12344456788899m")
        openHand = []
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QingYiSe]))
        
        // qingyise
        closeHand = TestHand.constructHand("12344499m")
        openHand = TestHand.constructHand("555777m")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QingYiSe]))
        
        // yaojiu
        closeHand = TestHand.constructHand("123s78999m")
        openHand = TestHand.constructHand("111m999p")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.YaoJiu]))
        
        // jingou
        closeHand = TestHand.constructHand("88s")
        openHand = TestHand.constructHand("111444m555999p")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.JinGou]))
        
        // pongpong
        closeHand = TestHand.constructHand("111333s99m")
        openHand = TestHand.constructHand("111m555p")
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.PongPongHu]))
        
        // MARK: all cases qidui and yaojiu, these two can't coexist!!
        // qidui == yaojiu
        closeHand = TestHand.constructHand("112233m99s778899p")
        openHand = []
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QiDuiZi]) ||
                  result.containsSameElements(as: [.YaoJiu]))
        
        // long qidui > yaojiu
        closeHand = TestHand.constructHand("11112233m778899p")
        openHand = []
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.LongQiDui]) ||
                  result.containsSameElements(as: [.YaoJiu]))
        // qingyaojiu == qingqidui
        closeHand = TestHand.constructHand("112233m99s778899p")
        openHand = []
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        XCTAssert(result.containsSameElements(as: [.QiDuiZi]) ||
                  result.containsSameElements(as: [.YaoJiu]))
        
        // qinglong > qingyaojiu + 1 gen
        closeHand = TestHand.constructHand("11223377889999m")
        openHand = []
        result = BloodyAnalyzer.findBestFanGroup(closeHand: closeHand, openHand: openHand)
        print(result.map({$0.name}))
        XCTAssert(result.containsSameElements(as: [.QingLong]))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
